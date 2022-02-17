ARG BASE
FROM ${BASE}

RUN echo "APT::Get::Assume-Yes \"true\";" >/etc/apt/apt.conf.d/90assumeyes \
	&& ln -f -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& apt-get update -y \
	&& apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
		sudo curl jq \
		build-essential git \
		python3 python3-venv python3-dev python3-pip

RUN useradd -m docker \
	&& echo "docker ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN runner_version="$(curl https://api.github.com/repos/actions/runner/releases/latest | jq --raw-output .tag_name | sed 's/^v//')"	\
	&& cd /home/docker \
	&& mkdir actions-runner \
	&& cd actions-runner \
	&& curl -O -L https://github.com/actions/runner/releases/download/v${runner_version}/actions-runner-linux-x64-${runner_version}.tar.gz \
	&& tar xzf ./actions-runner-linux-x64-${runner_version}.tar.gz \
	&& chown -R docker ~docker \
	&& rm ./actions-runner-linux-x64-${runner_version}.tar.gz

RUN /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

RUN hub_version="$(curl https://api.github.com/repos/github/hub/releases/latest | jq --raw-output .tag_name | sed 's/^v//')" \
	&& cd /home/docker \
	&& curl -O -L https://github.com/github/hub/releases/download/v${hub_version}/hub-linux-amd64-${hub_version}.tgz \
	&& tar xzf ./hub-linux-amd64-${hub_version}.tgz \
	&& cd hub-linux-amd64-${hub_version} \
	&& ./install \
	&& cd /home/docker \
	&& rm -rf hub-linux-amd64-${hub_version}.tgz hub-linux-amd64-${hub_version}

USER docker
ENTRYPOINT ["./start.sh"]
