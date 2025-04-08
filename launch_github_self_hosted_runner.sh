#!/bin/bash

ls

# INFO: 
REG_TOKEN_FILE_NAME=/home/docker/token.secret

# INFO: 
if [ ! -e "${REG_TOKEN_FILE_NAME}" ]; then
    echo Token file ${REG_TOKEN_FILE_NAME} does not exist.
    exit 1
fi

# INFO: 
REG_TOKEN=$(cat ${REG_TOKEN_FILE_NAME})

# INFO: 
if [ -z "${REG_TOKEN}" ]; then
    echo Token is empty, cannot proceed.
    exit 1
fi

# Next we move into our previously created action-runner folder and begin the
# startup process. We indicate which org we are connecting to, provide our
# newly retrieved registration token and add any labels specific to this
# machine. We will use these labels later in a repository workflow file to
# ensure the correct remote runner picks up our jobs. The cleanup function
# will handle unregistering and removing the runner from the org in the case
# the Docker container is stopped.

cd /home/docker/actions-runner

# Create the runner and start the configuration experience
echo -e "\n" | ./config.sh --url https://github.com/archipelagos/rp0_yocto --token ${REG_TOKEN} --labels yocto,x64,linux

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
