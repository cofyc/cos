all::

.PHONY: all install uninstall clean release debug clean

debug-costatsd:
	xcodebuild -project CoStats.xcodeproj -target costatsd -configuration Debug build

debug:
	xcodebuild -project CoStats.xcodeproj -alltargets -configuration Debug build

release:
	xcodebuild -project CoStats.xcodeproj -alltargets -configuration Release build

install: uninstall release
	cp -r "build/Release/CoStats.app" "/Applications"

uninstall:
	rm -rf "/Applications/CoStats.app"

test: debug
	open "build/Debug/CoStats.app/"

test-release: release
	open "build/Release/CoStats.app/"

clean:
	rm -rf build
	rm -rf *.dmg
	rm -rf package/*.app
	rm -rf appcast.xml

package: release
	./package.py

all:: debug
