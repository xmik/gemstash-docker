# Run [gemstash](https://github.com/bundler/gemstash) server in a docker container

Gemstash is a ruby gems source (https://rubygems.org for instance) caching mirror. It speeds up `bundle install` quite a lot.

This project allows to run it in a docker container.

## Usage

```
docker run -d -p '9292:9292' -v /tmp/gemstash-data:/root/.gemstash --name gemstash xmik/gemstash
```

### Custom config

After the server container is started, you can use regular gemstash cli to change its config, authorize, etc.

```
# change config
docker exec -it gemstash_server gemstash setup --redo
# and don't forget to restart the container afterwards
docker restart gemstash_server

# authorize to interact with private gems
docker exec -it gemstash_server gemstash authorize ...
```

Note: if you need to run gemstash on another server port, rather than changing config, simply provide different port binding argument to docker run. E.g. `docker run -p '5000:9292' ...` will bind gemstash server to port 5000.

Some other settings (for instance postgres, memcached) might also change the way gemstash_server container is started as you'd likely want to link corresponding docker containers.

### Db backup

https://docs.docker.com/engine/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes


## Development
```
./tasks build # build docker image
./tasks test # run Bats tests
```
