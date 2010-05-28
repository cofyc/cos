

all:
	pushd `pwd`/../ &>/dev/null; make debug-costatsd; popd

indent:
	test -e ~/.indent.pro && cp ~/.indent.pro .indent.pro
	sed -n 's/.*typedef\s.*\s\([a-zA-Z_]\+\);/\1/p' *.[chm] | xargs \
		-Itype echo '-T type' >> .indent.pro
	# additional typenames
	echo '-T pid_t' >> .indent.pro
	indent *.[chm]
	rm -f .indent.pro
	rm -f *~
