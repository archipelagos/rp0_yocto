#!/bin/bash

# The last bit is the start.sh script. To make the image modular and usable
# for others, two environment variables will be passed in when spinning up a
# container - The organization name this Runner will be made available to and
# a Personal Access Token needed to retrieve a registration token for your
# org. The PAT used will need repo, workflow and admin:org access rights
# given.

ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

# Next we move into our previously created action-runner folder and begin the
# startup process. We indicate which org we are connecting to, provide our
# newly retrieved registration token and add any labels specific to this
# machine. We will use these labels later in a repository workflow file to
# ensure the correct remote runner picks up our jobs. The cleanup function
# will handle unregistering and removing the runner from the org in the case
# the Docker container is stopped.

cd /home/docker/actions-runner

./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN} --labels yocto,x64,linux

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!