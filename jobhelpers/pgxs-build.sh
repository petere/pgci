for pg in postgresql-*.bin.tar.xz; do
	tar xf $pg
done

for dir in $PWD/postgresql-*.bin/usr/local/pgsql/bin; do
(
	PATH=$dir:$PATH
	export LD_LIBRARY_PATH=$(pg_config --libdir)
	export USE_PGXS=1

	pgversion=$(pg_config --version | awk '{print $2}')

	mkdir build-$pgversion
	git archive --format=tar HEAD | (cd build-$pgversion && tar xf -)
	cd build-$pgversion

	make -k all
	make -k install
	/srv/pgci/jobhelpers/wpti make -i installcheck || echo unstable | md5sum
)
done
