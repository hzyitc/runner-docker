#!/bin/bash

ACCESS_TOKEN="${ACCESS_TOKEN}"
REPO="${REPO}"
LABELS="${LABEL}"

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" "https://api.github.com/repos/${REPO}/actions/runners/registration-token" | jq .token --raw-output)

cd /home/docker/actions-runner
./config.sh --unattended --url "https://github.com/${REPO}" --token "${REG_TOKEN}" --labels "${LABELS}" --ephemeral

cleanup() {
	echo "Removing runner..."
	./config.sh remove --unattended --token "${REG_TOKEN}"
}
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
