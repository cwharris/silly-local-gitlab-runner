set -Eeox pipefail

cd $(dirname "$(realpath "$0")")

# kill and remove the existing container if not already done
docker stop gitlab-runner || :
docker container rm gitlab-runner || :

# start the gitlab runner
docker run -d \
  --name gitlab-runner \
  -v $PWD:$PWD \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest

# config gitlab runner to trust this repo
docker exec -it -w $PWD gitlab-runner git config --global --add safe.directory "*"

# run the build step of the .gitlab-ci.yml
docker exec -it -w $PWD gitlab-runner gitlab-runner exec docker \
    --docker-privileged \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
    build

# kill and remove the existing container
docker stop gitlab-runner
docker container rm gitlab-runner
