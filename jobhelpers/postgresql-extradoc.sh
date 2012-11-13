test -e GNUmakefile || ./configure
cd doc/src/sgml
make -k xslthtml postgres-A4.pdf postgres-US.pdf postgres.info postgres-A4.fo postgres-US.fo

FOP_OPTS='-Xmx448m'
export FOP_OPTS
fop -fo postgres-A4.fo -pdf postgres-A4-fop.pdf
fop -fo postgres-US.fo -pdf postgres-US-fop.pdf
