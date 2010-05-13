all::

.PHONY: all install uninstall clean release debug clean

release:
	xcodebuild -project CoStats.xcodeproj build

install: uninstall release
	cp -r build/Release/CoStats.app "/Applications"

uninstall:
	rm -rf "/Applications/CoStats.app"

clean:
	rm -rf build
	rm -rf *.dmg
	rm -rf appcast.xml

package: release
	./package.py

all:: release
