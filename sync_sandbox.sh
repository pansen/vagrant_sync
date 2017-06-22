#!/usr/bin/env bash

set -x
set -e

# watcher script to replace `vagrant rsync-auto`, which is terribly slow and
# unreliable, cause it frequently hangs in 100% cpu loops
#
# see http://unix.stackexchange.com/a/163816 for the bash-magic included

here="$(pwd)/$(dirname $0)"

# connection to the local dev box
SSH_PORT=2226
SSH_CMD="ssh -p ${SSH_PORT} \
    -o User=vagrant \
    -o IdentityFile=~/.vagrant.d/insecure_private_key \
    -o IdentitiesOnly=yes \
    -o ForwardAgent=no \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null"

# definition of sources to sync and appropriate destination dirs in the dev box
SRC_1 = "${here}/../foo/"
DEST_1 = "/srv/foo/"

SRC_1 = "${here}/../bar/"
DEST_1 = "/srv/bar/"


cd "${SRC_1}" && watchexec \
    --ignore .git \
    --ignore .idea \
    --ignore app/cache \
    --ignore app/logs \
    --ignore vendor \
    --ignore uploads \
    --exts php,yml,sass,js,css,html,twig \
    "time rsync -av \
        -e \"${SSH_CMD}\" \
        \"${SRC_1}\"/ \
        127.0.0.1:${DEST_1} \
        --inplace \
        --delete \
        --omit-dir-times \
        --exclude=app/cache \
        --exclude=app/logs \
        --exclude=app/bootstrap.php.cache \
        --exclude=app/config/parameters.yml \
        --exclude=tools \
        --exclude=vendor \
        --exclude=uploads \
        --exclude=node_modules \
        --exclude=.DS_Store \
        --exclude=.idea \
        --exclude=.git \
        "&
# Storing the background process' PID.
SRC_1_sync_pid=$!
# Trapping SIGINTs so we can send them back to $xx_pid.
trap "kill -2 ${SRC_1_sync_pid}" 2


cd "${SRC_2}" && watchexec \
	--ignore .git \
	--ignore .idea \
	--ignore app/cache \
	--ignore app/logs \
	--ignore vendor \
	--ignore uploads \
	--exts php,yml,sass,js,css,html,twig \
	"time rsync -av \
        -e \"${SSH_CMD}\" \
		\"${SRC_2}\"/ \
		127.0.0.1:${DEST_2} \
		--inplace \
		--delete \
		--omit-dir-times \
		--exclude=app/cache \
		--exclude=app/logs \
		--exclude=app/bootstrap.php.cache \
		--exclude=app/config/parameters.yml \
		--exclude=tools \
		--exclude=vendor \
		--exclude=uploads \
		--exclude=node_modules \
		--exclude=.DS_Store \
		--exclude=.idea \
		--exclude=.git \
		"&
# Storing the background process' PID.
SRC_2_sync_pid=$!
# Trapping SIGINTs so we can send them back to $xx_pid.
trap "kill -2 ${SRC_2_sync_pid}" 2



# In the meantime, wait for $xx_pid to end.
wait ${SRC_1_sync_pid} ${SRC_2_sync_pid}
