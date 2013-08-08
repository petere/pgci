# Continuous integration service for PostgreSQL

This is a collection of deployment and configuration pieces to set up
a continuous integration service running Jenkins for PostgreSQL.  I'm
running it at <http://pgci.eisentraut.org/>, but you can fork it and
run your own (or contribute to mine).

## Installation

Installation is currently supported on Debian squeeze (6.0) and Ubuntu precise (12.04 LTS).

On a fresh installation, clone the repository to `/srv/pgci`
(this exact path is currently required; I'm working on a way to avoid
that), and run

    puppet apply --modulepath=modules/ manifests/pgci.pp

If the Jenkins configuration is changed while Jenkins is running, you
need to go into Jenkins and choose "reload configuration from disk".

## Local installation

For testing and development, use Vagrant and just call

    vagrant up

This will create a virtual machine with Jenkins running on port 50080
on the host.

## Manual setup

Some pieces should be set up manually:

- `dpkg-reconfigure icinga-cgi` for the `icingaadmin` password
- `/etc/aliases`, to get system email
- Jenkins users and authentication
- cron job from `tools/crontab` if desired
