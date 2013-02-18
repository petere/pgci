test -e GNUmakefile || ./configure
cd doc/src/sgml
make -k xslthtml postgres-A4.pdf postgres-US.pdf postgres.info postgres-A4.fo postgres-US.fo epub

JAVA_ARGS='-Xmx700m -Xincgc'
export JAVA_ARGS
/usr/bin/time -v fop -fo postgres-A4.fo -pdf postgres-A4-fop.pdf
/usr/bin/time -v fop -fo postgres-US.fo -pdf postgres-US-fop.pdf
