#!/bin/sh
#date=`date +%Y-%m-%dT%H%M%S`
#tmpdir=`mktemp -d`
#cat - > $tmpdir/message.txt
#/usr/bin/ripmime -d $tmpdir -i $tmpdir/message.txt 2>&1 >> /tmp/log
#mv $tmpdir /mail/$date
#exit 0

date=`date +%Y-%m-%dT%H%M%S`
tmpdir=$HOME/$date
mkdir $tmpdir
cat - > $tmpdir/message.txt
/usr/bin/ripmime -d $tmpdir -i $tmpdir/message.txt 2>&1 >> $HOME/riplog.txt
exit 0
