all::

.PHONY: all install uninstall clean release debug clean

release:
	xcodebuild -project CoStats.xcodeproj build

install: uninstall
	cp -r build/Release/CoStats.app "/Applications"

uninstall:
	rm -rf "/Applications/CoStats.app"

debug:
	xcodebuild -project CoStats.xcodeproj build

clean:
	rm -rf build

all:: debug
