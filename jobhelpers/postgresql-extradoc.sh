test -e GNUmakefile || ./configure
cd doc/src/sgml
make -k xslthtml postgres-A4.pdf postgres-US.pdf postgres.info postgres-A4.fo postgres-US.fo
