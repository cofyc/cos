all::

release:
	xcodebuild -project CoStats.xcodeproj build

install:
	rm -rf "/Applications/CoStats.app"
	cp -r build/Release/CoStats.app "/Applications"

debug:
	xcodebuild -project CoStats.xcodeproj build

clean:
	rm -rf build

all:: debug
