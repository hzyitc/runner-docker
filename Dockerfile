ARG BASE
FROM ${BASE}

ARG RUNNER_VERSION="2.287.1"
ARG HUB_VERSION="2.14.2"

RUN ln -f -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& apt-get update -y \
	&& apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
		sudo curl jq \
		build-essential git \
		python3 python3-venv python3-dev python3-pip

RUN useradd -m docker \
	&& echo "docker ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN cd /home/docker \
	&& mkdir actions-runner \
	&& cd actions-runner \
	&& curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
	&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
	&& chown -R docker ~docker \
	&& rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

RUN cd /home/docker \
	&& curl -O -L https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz \
	&& tar xzf ./hub-linux-amd64-${HUB_VERSION}.tgz \
	&& cd hub-linux-amd64-${HUB_VERSION} \
	&& ./install \
	&& cd /home/docker \
	&& rm -rf hub-linux-amd64-${HUB_VERSION}.tgz hub-linux-amd64-${HUB_VERSION}

USER docker
ENTRYPOINT ["./start.sh"]
