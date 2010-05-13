#!/usr/bin/env python2.6

import os
import plistlib
import commands
import time

plist = plistlib.readPlist("build/Release/CoStats.app/Contents/Info.plist")
version = plist["CFBundleVersion"]
dmgfile = "CoStats-%s.dmg" % version
priv_key = "%s/.ssh/dsa_priv.pem" % os.path.expanduser('~')

print("Generating DMG file...")
os.system("rm %s" % dmgfile)
os.system("hdiutil create -srcfolder build/Release/CoStats.app %s" % dmgfile)

print(priv_key)
print("Signing %s..." % dmgfile)
signed = commands.getoutput("./sign_update.rb %s %s" % (dmgfile, priv_key))

date = time.strftime("%a, %d %b %Y %H:%M:%S %z")
appcast_template = 'appcast.template.xml'
appcast = 'appcast.xml'
