wget -N http://ftp.postgresql.org/pub/dev/pg_bsd_indent-1.2.tar.gz
echo '34991f8830eb4f8125b423792155a4763dded4a3  pg_bsd_indent-1.2.tar.gz' | sha1sum -c
tar xvf pg_bsd_indent-1.2.tar.gz
make -C pg_bsd_indent/

make -C src/tools/entab

PATH=$PWD/pg_bsd_indent:$PWD/src/tools/entab:$PATH

wget -O src/tools/pgindent/typedefs.list http://buildfarm.postgresql.org/cgi-bin/typedefs.pl

src/tools/pgindent/pgindent

git diff --src-prefix=original/ --dst-prefix=pgindent/ --patch --stat --dirstat >pgindent.diff

./configure
make
make check
make -C contrib
#make -C contrib check
