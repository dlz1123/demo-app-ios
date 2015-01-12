#!/bin/sh
 
#  build_Script.sh
#  iOS_IMKit_Demo
#
#  Created by Heq.Shinoda on 14-07-11.
#  Copyright (c) 2014年 Heq.Shinoda All rights reserved.


BIN_DIR="bin"
if [ ! -d "$BIN_DIR" ]; then
mkdir -p $BIN_DIR
fi

ipafilename="RongIMKitDemo"
xcodebuild clean -configuration "Debug"      
targetName="RongIMKitDemo"
buildtime=`date "+%Y%m%d%H%M"`
current=`PWD`
 
xcodebuild -project RongIMKit-Demo-iOS.xcodeproj -target "${targetName}" -configuration "Debug"  -sdk iphoneos clean build
appfile="./Build/Debug-iphoneos/RongIMKit-Demo-iOS.app"


ipapath="${current}/${BIN_DIR}/${targetName}_${buildtime}.ipa"
#xcodebuild clean archive -target "${targetName}" -sdk iphoneos -configuration AdHoc CODE_SIGN_IDENTITY="iPhone Distribution: Feinno Communication Tech Co. Ltd."

echo "***开始打ipa包****"
xcrun -sdk iphoneos PackageApplication -v ${appfile}  -o ${ipapath} # --sign "iPhone Distribution: Feinno Communication Tech Co. Ltd." --embed "RCloud_UIComponent_Distribution.mobileprovision"
#/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$appfile" -o "$ipapath" --sign "iPhone Distribution: Feinno Communication Tech Co. Ltd."

