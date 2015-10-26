if ! grep -qw fop doc/src/sgml/Makefile; then
	cat <<'EOF' >src/Makefile.custom
.SECONDARY: postgres-A4.fo postgres-US.fo

%-fop.pdf: %.fo
	/usr/bin/time -v fop -fo $< -pdf $@
EOF
fi

if ! grep -qw epub doc/src/sgml/Makefile; then
        cat <<'EOF' >>src/Makefile.custom

epub: postgres.epub
postgres.epub: postgres.xml
	dbtoepub $<
EOF
fi

JAVA_ARGS='-Xmx1000m -Xincgc'
export JAVA_ARGS

test -e GNUmakefile || ./configure
cd doc/src/sgml
make -k xslthtml postgres-A4.pdf postgres-US.pdf postgres.info postgres-A4-fop.pdf postgres-US-fop.pdf epub
