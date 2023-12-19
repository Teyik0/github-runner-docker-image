FROM ubuntu:latest

ARG GITHUB_REPOSITORY_URL
ARG GITHUB_RUNNER_TOKEN

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl

# Install docker on the image and mount the docker socket
RUN apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker.io

# Install the runner
WORKDIR /actions-runner

RUN /usr/bin/curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz && \
    echo "5d13b77e0aa5306b6c03e234ad1da4d9c6aa7831d26fd7e37a3656e77153611e actions-runner-linux-arm64-2.311.0.tar.gz" | sha256sum -c && \
    tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz && \
    chmod +x bin/installdependencies.sh

ENV RUNNER_ALLOW_RUNASROOT=1
RUN ./config.sh --url ${GITHUB_REPOSITORY_URL} --token ${GITHUB_RUNNER_TOKEN}

ENTRYPOINT ["./run.sh"]

# Start the runner
# docker build -t github-runner --build-arg="GITHUB_REPOSITORY_URL=<url>" --build-arg="GITHUB_RUNNER_TOKEN=<token>" .
# docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock --name github-runner -it github-runner
