#!/bin/bash
set -x
kextdir="$2/System/Library/Extensions"
HDAbinary="$kextdir/AppleHDA.kext/Contents/MacOS/AppleHDA"
HDAplist="$kextdir/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext/Contents/Info.plist"
AICPMbin="$kextdir/AppleIntelCPUPowerManagement.kext/Contents/MacOS/AppleIntelCPUPowerManagement"
SNBbinary="$kextdir/AppleIntelSNBGraphicsFB.kext/Contents/MacOS/AppleIntelSNBGraphicsFB"
IVYbinary="$kextdir/AppleIntelFramebufferCapri.kext/Contents/MacOS/AppleIntelFramebufferCapri"
RTCBinary="$kextdir/AppleRTC.kext/Contents/MacOS/AppleRTC"
PatchHDA () {
unzip $1 -d .
workdir=`echo $(basename $1) | awk -F. '{print $1}'`
perl ./patch-hda.pl "`cat ./$workdir/codec`" -s "$kextdir"
rm -f "$kextdir"/AppleHDA.kext/Contents/Resources/*.{xml,zlib}
install -m 644 -o root -g wheel ./$workdir/layout/*.* "$kextdir"/AppleHDA.kext/Contents/Resources
/usr/libexec/plistbuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:HDAConfigDefault'" "$HDAplist"
/usr/libexec/plistbuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:PostConstructionInitialization'" "$HDAplist"
/usr/libexec/plistbuddy -c "Merge ./$workdir/ahhcd.plist ':IOKitPersonalities:HDA Hardware Config Resource'" "$HDAplist"
}
while read vanilla; do
patch=`echo $vanilla | awk -F '<=>' '{print $3}'`
case $patch in
aicpm)	perl ./AICPMPatch.pl "$AICPMbin" --patch
		;;
hda_4x30_l)		PatchHDA ./4x30_lion.zip
				;;
hda_4x30_m)		PatchHDA ./4x30_ml.zip
				;;
hda_4x40_l)		PatchHDA ./4x40_lion.zip
				;;
hda_4x40_m)		PatchHDA ./4x40_ml.zip
				;;
hda_6xx0_l)		PatchHDA ./6xx0_lion.zip
				;;
hda_6xx0_m)		PatchHDA ./6xx0_ml.zip
				;;
hda_4x0s_m)		PatchHDA ./4x0s_ml.zip
				;;
fbsnb)	perl -pi -e 's|\x01\x02\x04\x00\x10\x07\x00\x00\x10\x07\x00\x00\x05\x03\x00\x00\x02\x00\x00\x00\x30\x00\x00\x00\x02\x05\x00\x00\x00\x04\x00\x00\x07\x00\x00\x00\x03\x04\x00\x00\x00\x04\x00\x00\x09\x00\x00\x00\x04\x06\x00\x00\x00\x04\x00\x00\x09\x00\x00\x00|\x01\x02\x03\x00\x10\x07\x00\x00\x10\x07\x00\x00\x06\x02\x00\x00\x00\x01\x00\x00\x09\x00\x00\x00\x05\x03\x00\x00\x02\x00\x00\x00\x30\x00\x00\x00\x04\x06\x00\x00\x00\x08\x00\x00\x09\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00|g' "$SNBbinary"
		;;
fbivy)	perl -pi -e 's|\x04\x00\x00\x81.{107}\x04\x00\x66\x01.{108}|\x08\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x66\x01\x01\x02\x04\x02\x00\x00\x00\x04\x00\x00\x00\x01\x00\x00\x00\x20\x10\x07\x00\x00\x10\x07\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05\x03\x00\x00\x02\x00\x00\x00\x30\x02\x00\x00\x02\x05\x00\x00\x00\x04\x00\x00\x07\x01\x00\x00\x03\x04\x00\x00\x00\x04\x00\x00\x07\x01\x00\x00\x04\x06\x00\x00\x00\x08\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00|' "$IVYbinary"
		;;
fbivy_mav)	perl -pi -e 's|\x04\x00\x00\x81.{107}\x04\x00\x66\x01.{108}|\x08\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x66\x01\x01\x02\x04\x02\x00\x00\x00\x04\x00\x00\x00\x01\x00\x00\x00\x40\x10\x07\x00\x00\x10\x07\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05\x03\x00\x00\x02\x00\x00\x00\x30\x02\x00\x00\x02\x05\x00\x00\x00\x04\x00\x00\x07\x04\x00\x00\x03\x04\x00\x00\x00\x04\x00\x00\x81\x00\x00\x00\x04\x06\x00\x00\x00\x08\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x11\x00\x00\x00\x00\x00\x00\x00\x00|' "$IVYbinary"
		;;
aprtc)	perl -pi -e 's|\x75\x30\x89\xd8|\xeb\x30\x89\xd8|' "$RTCBinary"
		;;
rtcmav)	perl -pi -e 's|\x75\x2e\x0f\xb6|\xeb\x2e\x0f\xb6|' "$RTCBinary"
		;;
esac	
done < $1
/usr/libexec/PlistBuddy -c "Set :KextCacheRebuild yes" /tmp/PBI.plist