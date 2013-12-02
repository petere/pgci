./configure CC=clang CFLAGS='-O1 -g -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls' --enable-cassert --with-tcl --without-perl --without-python --with-krb5 --with-pam --with-ldap --with-openssl --with-libxml --with-libxslt --with-gssapi --enable-thread-safety --enable-nls --with-ossp-uuid
make world
status=0
make check-world || status=$?
if [ $status -ne 0 ]; then
	for file in $(find . -wholename '*/log/*.log'); do
		/srv/pgci/jobhelpers/asan_symbolize.py <$file >$file.asan
	done
fi
(exit $status)
