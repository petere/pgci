./configure --enable-debug --enable-depend --enable-cassert --with-tcl --with-perl --with-python --with-krb5 --with-pam --with-ldap --with-openssl --with-libxml --with-libxslt --with-gssapi --enable-thread-safety --enable-nls --with-ossp-uuid
make world
make maintainer-check
make check-world
