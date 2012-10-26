./configure --enable-debug --enable-depend --enable-cassert --with-tcl --with-perl --with-python --with-krb5 --with-pam --with-ldap --with-openssl --with-libxml --with-libxslt --with-gssapi --enable-thread-safety --enable-nls --with-ossp-uuid

if grep -qw world GNUmakefile; then
	make -k world
else
	make -k all
	make -k -C contrib all
	make -k -C doc/src/sgml all
fi

if grep -qw maintainer-check GNUmakefile; then
	make -k maintainer-check
fi

if grep -qw check-world GNUmakefile; then
	make -k check-world
else
	make -k check
fi
