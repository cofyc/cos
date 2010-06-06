#!/usr/bin/env python2.6

import os
import sys
import plistlib
import commands
import time
from string import Template

app = "build/Release/CoStats.app"
plist = plistlib.readPlist("%s/Contents/Info.plist" % app)
version = plist["CFBundleVersion"]
version_string = plist["CFBundleShortVersionString"]
dmgfile = "CoStats-%s.dmg" % version
priv_key = "%s/.ssh/dsa_priv.pem" % os.path.expanduser('~')
date = time.strftime("%a, %d %b %Y %H:%M:%S %z")
appcast = "appcast.xml"
appcast_url = "http://yechengfu.com/cos/%s" % appcast
url = "http://github.com/downloads/Cofyc/cos/%s" % dmgfile
release_notes_file = "RelNotes"
description = open(release_notes_file, "r").read().replace('\n', '<br/>')

appcast_tpl = """<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>CoStats</title>
        <link>http://github.com/Cofyc/cos</link>
        <description>C Of Stats</description>
        <language>en</language>
        <item>
            <title>CoStats $version_string</title>
            <pubDate>$date</pubDate>l
            <enclosure url="$url" sparkle:version="$version" length="$length" sparkle:dsaSignature="$signed" type="application/octet-stream" />
            <description><![CDATA[$description]]>
            </description>
        </item>
    </channel>
</rss>
"""

print("---> Generating DMG file...")
os.system("rm -rf package/CoStats.app")
os.system("cp -rf build/Release/CoStats.app package/")
os.system("rm -rf %s" % dmgfile)
os.system("hdiutil create -volname CoStats-%s -format UDBZ -srcfolder package %s" % (version, dmgfile))

print("---> Signing %s..." % dmgfile)
# borrowed from sunpinyin's macosx wrapper or use Sparkle's sign_update.rb
signed = commands.getoutput('openssl dgst -sha1 -binary < "%s" | openssl dgst -dss1 -sign "%s" | openssl enc -base64' % (dmgfile, priv_key))
print("---> %s"  % signed)

print("---> Getting App Size...")
length = commands.getoutput("du -sb %s | cut -f 1" % app)
print("---> %s" % length)

print("---> Generating %s..." % appcast)
appcast_template = Template(appcast_tpl)
output = open(appcast, "w")
output.write(appcast_template.substitute
        ( version=version # compared version
        , version_string=version_string
        , date=date
        , url=url
        , length=length
        , signed=signed
        , description=description
        ).encode("utf-8")
    )
output.close()
print("---> OK.")

print("""
Done!
    1. Publish %s to %s
    2. Publish %s to %s
""" % (dmgfile, url, appcast, appcast_url))

sys.exit(0)
