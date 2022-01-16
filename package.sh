#!/bin/bash
TARGET=$1
NAME=$(lua build/get_title.lua)
GAME="$NAME.love"
ROOTDIR=$(pwd)

if ! [ -f $ROOTDIR/$GAME ]; then
    echo "Game not found in $GAME - please run \"make build\" first."
    exit 1
fi

echo -n "Packaging for $TARGET... "

PKGDIR=$ROOTDIR/pkg/$TARGET
LIBDIR=$ROOTDIR/build/$TARGET

rm -rf $PKGDIR
mkdir -p $PKGDIR

cp -r $LIBDIR/* $PKGDIR

if [ $TARGET = "linux" ]; then
    cp -r $LIBDIR/squashfs-root $PKGDIR/squashfs-root
	cd $PKGDIR
	cat squashfs-root/bin/love $ROOTDIR/$GAME > squashfs-root/bin/$NAME
    chmod +x squashfs-root/bin/$NAME
    sed -i "s/NAME/$NAME/" squashfs-root/love.desktop
    appimagetool squashfs-root Elysion.AppImage
    rm -r squashfs-root
elif [ $TARGET = "windows" ]; then
	cd $PKGDIR
	cat $LIBDIR/love.exe $ROOTDIR/$GAME > $NAME.exe
elif [ $TARGET = "osx" ]; then
	mv $PKGDIR/love.app $PKGDIR/$NAME.app
	cp $ROOTDIR/$GAME $PKGDIR/$NAME.app/Contents/Resources/$GAME
else
	echo "ERROR: Unknown target: $TARGET"
	exit 1
fi

echo "DONE"
