# Faster Vagrant Sync

## Problem

All kinds of shared folders into vms or containers on non-linux machines are slow. Using `vagrant rsync-auto` is slow as well as the surrounding ruby layer creates up to many seconds delay before a sync is started. 

## Goal 

Create a fast one way sync solution. 

## Solution

We just use the Rust written `watchexec`, which is super fast in detecting local filesystem changes. The provided script `sync_sandbox.sh` is a working example for two symfony projects, with the typical includes and excludes. 

### Howto 

- [Install Rust](https://www.rust-lang.org/en-US/install.html)
- [Install watchexec](https://github.com/mattgreen/watchexec#installation)
- run the sync-script: `./sync_sandbox.sh`

## TODO / Not included

Since this is a one-way-sync, one important thing is missing. In that moment, when you call `composer install` inside of your sandbox, you need to sync the vendor dir back to the local machine to have all files in place for proper development and debugging. Usually this will be done in the provisioner (Ansible, Chef, Salt, ...) as the composer call will be triggered there as well. 