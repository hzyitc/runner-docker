ARG BASE
FROM ${BASE}

ARG RUNNER_VERSION="2.287.1"

RUN ln -f -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& apt-get update -y \
	&& apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
	sudo git curl jq build-essential \
	python3 python3-venv python3-dev python3-pip

RUN useradd -m docker \
	&& cd /home/docker \
	&& mkdir actions-runner \
	&& cd actions-runner \
	&& curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
	&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
	&& chown -R docker ~docker

RUN /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

USER docker
ENTRYPOINT ["./start.sh"]
