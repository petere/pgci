./configure
echo 'VERSION := $(VERSION)$(VERSION_EXTRA)' >src/Makefile.custom
GIT_COMMIT_ABBREV=$(echo $GIT_COMMIT | sed 's/^\(.......\).*$/\1/')
make distcheck VERSION_EXTRA='-j'$BUILD_NUMBER'-g'$GIT_COMMIT_ABBREV
