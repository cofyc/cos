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
dmgfile = "CoStats-%s.dmg" % version
priv_key = "%s/.ssh/dsa_priv.pem" % os.path.expanduser('~')
date = time.strftime("%a, %d %b %Y %H:%M:%S %z")
appcast = "appcast.xml"
appcast_url = "http://yechengfu.com/cos/%s" % appcast
url = "http://github.com/downloads/Cofyc/cos/%s" % dmgfile
description = """
    <h2>* New Features</h2>
        Memory Stats
"""

appcast_tpl = """<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>CoStats</title>
        <link>http://github.com/Cofyc/ct</link>
        <description>C Of Stats</description>
        <language>en</language>
        <item>
            <title>CoStats $version</title>
            <pubDate>$date</pubDate>l
            <enclosure url="$url" sparkle:version="$version" length="$length" sparkle:dsaSignature="$signed" type="application/octet-stream" />
            <description><![CDATA[$description]]>
            </description>
        </item>
    </channel>
</rss>
"""

print("Generating DMG file...")
os.system("rm -rf %s" % dmgfile)
os.system("hdiutil create -srcfolder build/Release/CoStats.app %s" % dmgfile)

print("Signing %s..." % dmgfile)
signed = commands.getoutput("./sign_update.rb %s %s" % (dmgfile, priv_key))
print("---> %s"  % signed)

print("Get App Size...")
length = commands.getoutput("du -sb %s | cut -f 1" % app)
print("---> %s" % length)

print("Generating %s..." % appcast)
appcast_template = Template(appcast_tpl)
output = open(appcast, "w")
output.write(appcast_template.substitute
        ( version=version
        , date=date
        , url=url
        , length=length
        , signed=signed
        , description=description
        ).encode("utf-8")
    )
output.close()

print("""Done!
    1. Publish %s to %s
    2. Publish %s to %s
""" % (dmgfile, url, appcast, appcast_url))

sys.exit(0)
