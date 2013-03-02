cat <<'EOF' >src/Makefile.custom
.SECONDARY: postgres-A4.fo postgres-US.fo

%-fop.pdf: %.fo
	/usr/bin/time -v fop -fo $< -pdf $@
EOF

JAVA_ARGS='-Xmx700m -Xincgc'
export JAVA_ARGS

test -e GNUmakefile || ./configure
cd doc/src/sgml
make -k xslthtml postgres-A4.pdf postgres-US.pdf postgres.info postgres-A4-fop.pdf postgres-US-fop.pdf epub
