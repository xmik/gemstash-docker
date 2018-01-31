load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

@test "initialize tests" {
  if [[ "${docker_container}" == "" ]]; then
    echo "fail! docker_container not set"
    return 1
  fi
  if [[ "${volume_root_dir}" == "" ]]; then
    echo "fail! volume_root_dir not set"
    return 1
  fi
  docker stop ${docker_container} || echo "No ${docker_container} container to stop"
  docker rm ${docker_container} || echo "No ${docker_container} container to remove"
  run sudo rm -rf "${volume_root_dir}" || { echo "failed to rm ${volume_root_dir}" ; exit 1; }
  echo "${output}"
  # those directories will be cinder volumes, so make this closer to production
  mkdir -p "${data_dir}/lost+found"
}
@test "server container is running" {
  docker run --name ${docker_container} -d\
    -p 9292:9292\
    -v "${data_dir}/inner":/root/.gemstash\
    -v /etc/localtime:/etc/localtime\
    "${this_image_name}:${this_image_tag}"
  run /bin/bash -c "for i in {1..10}; do { echo \"trial: \$i\" && docker logs ${docker_container} | grep \"Listening\"; } && break || { sleep 1; [[ \$i == 10 ]] && exit 1; } done"

  run /bin/bash -c "docker logs ${docker_container}"
  assert_output --partial "Listening on tcp://0.0.0.0:9292"
  refute_output --partial "fatal"
  refute_output --partial "exited 1"
  assert_equal "$status" 0
}
@test "puma process is running in the container" {
  run docker exec ${docker_container} /bin/sh -c "ps aux"
  assert_output --partial "puma"
  assert_equal "$status" 0
}
@test "gemstash is available from docker host (localhost)" {
  run curl -L -i localhost:9292
  assert_output --partial "200 OK"
  assert_output --partial "RubyGems.org"
  assert_equal "$status" 0
}

@test "clean tests" {
  if [[ "${docker_container}" == "" ]]; then
    echo "fail! docker_container not set"
    return 1
  fi
  if [[ "${volume_root_dir}" == "" ]]; then
    echo "fail! volume_root_dir not set"
    return 1
  fi
  docker stop ${docker_container} || echo "No ${docker_container} container to stop"
  docker rm ${docker_container} || echo "No ${docker_container} container to remove"
  run sudo rm -rf "${volume_root_dir}" || { echo "failed to rm ${volume_root_dir}" ; exit 1; }
  echo "${output}"
}
