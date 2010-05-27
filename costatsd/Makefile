

all:
	pushd `pwd`/../; make debug-costatsd; popd

indent:
	test -e ~/.indent.pro && cp ~/.indent.pro .indent.pro
	sed -n 's/.*typedef\s.*\s\([a-zA-Z_]\+\);/\1/p' *.[ch] | xargs \
		-Itype echo '-T type' >> .indent.pro
	# additional typenames
	#echo '-T WINDOW' >> .indent.pro
	indent *.[ch]
	rm -f .indent.pro
	rm -f *~
