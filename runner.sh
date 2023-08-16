set -Eeox pipefail

cd $(dirname "$(realpath "$0")")

docker stop gitlab-runner || :
docker container rm gitlab-runner || :
docker run -d \
  --name gitlab-runner \
  -v $PWD/etc/gitlab-runner:/etc/gitlab-runner \
  -v $PWD:$PWD \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
docker exec -it -w $PWD gitlab-runner git config --global --add safe.directory "*"
docker exec -it -w $PWD gitlab-runner ls /etc/gitlab-runner
docker exec -it -w $PWD gitlab-runner gitlab-runner exec docker --docker-privileged build
docker stop gitlab-runner
docker container rm gitlab-runner
