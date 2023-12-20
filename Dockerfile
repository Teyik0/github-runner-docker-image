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

# Install sonar-scanner (optionnal)
COPY . /app
RUN apt-get install -y unzip && \
    unzip /app/SonarScanner_CLI_5.0.1.3006_Linux.zip && \
    mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Install the runner
WORKDIR /actions-runner

# FOR ARM64 IMAGES
# RUN /usr/bin/curl -o actions-runner-linux-arm64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz && \
#     echo "5d13b77e0aa5306b6c03e234ad1da4d9c6aa7831d26fd7e37a3656e77153611e actions-runner-linux-arm64-2.311.0.tar.gz" | sha256sum -c && \
#     tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz && \
#     chmod +x bin/installdependencies.sh

# FOR AMD64 IMAGES
RUN /usr/bin/curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz && \
    echo "29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c && \
    tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz && \
    chmod +x bin/installdependencies.sh

ENV RUNNER_ALLOW_RUNASROOT=1
RUN ./config.sh --url ${GITHUB_REPOSITORY_URL} --token ${GITHUB_RUNNER_TOKEN}

ENTRYPOINT ["./run.sh"]

# Start the runner
# docker buildx build --platform linux/amd64 --load -t github-runner --build-arg="GITHUB_REPOSITORY_URL=<url>" --build-arg="GITHUB_RUNNER_TOKEN=<token>" .
# docker run -v /var/run/docker.sock:/var/run/docker.sock --name github-runner -it github-runner --platform linux/amd64
