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

JAVA_ARGS='-Xmx1200m -Xincgc'
export JAVA_ARGS

test -e GNUmakefile || ./configure
cd doc/src/sgml
targets=''
if grep -q xslthtml Makefile; then
	targets="$targets xslthtml"
fi
targets="$targets postgres-A4.pdf postgres-US.pdf postgres.info epub"
if grep -q -- -fop.pdf Makefile; then
	targets="$targets postgres-A4-fop.pdf postgres-US-fop.pdf"
fi

make -k $targets
