all::

.PHONY: all install uninstall clean release debug clean

release:
	xcodebuild -project CoStats.xcodeproj build

install: uninstall release
	cp -r build/Release/CoStats.app "/Applications"

uninstall:
	rm -rf "/Applications/CoStats.app"

debug:
	xcodebuild -project CoStats.xcodeproj build

clean:
	rm -rf build
	rm -rf *.dmg

package: build/Release/CoStats.app
	./package.py

all:: debug
