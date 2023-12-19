# github-runner-docker-image

This repository contains the Dockerfile for the GitHub Actions self-hosted runner.

## Start the runner

`docker build -t github-runner --build-arg="GITHUB_REPOSITORY_URL=<url>" --build-arg="GITHUB_RUNNER_TOKEN=<token>" .`

`docker run -v /var/run/docker.sock:/var/run/docker.sock --name github-runner`
