#!/bin/bash

# This script requries K-S-V's AdobeHDS tool found here: https://raw.github.com/K-S-V/Scripts/master/AdobeHDS.php

COUNTRY="Canada"
ADOBEHDS="/usr/local/bin/AdobeHDS.php"
DIR="/shared/server/Videos/Hockey"

curl -s "http://www.tsn.ca/videohub/Default.aspx?collection=181" | grep TVE_Obj | perl -pe 's/Id":/\n/g' | perl -pe 's/,"Name":"WJHC: /-/; s/","Desc".*//; s/\.? /_/g' | grep $COUNTRY | while read NUM1_NAME; do
	NUM1=`echo $NUM1_NAME | awk -F '-' '{print $1}'`
	NAME=`echo $NUM1_NAME | awk -F '-' '{print $2}'`
	if [ -d "$DIR/$NUM1" ]; then
		continue;
	fi
	NUM2_DATE=`curl -s --globoff 'http://capi.9c9media.com/destinations/tsn_web/platforms/desktop/contents/'$NUM1'?$include=[Id,Name,Desc,ShortDesc,Type,Owner,Media,Season,Episode,Genres,Images,ContentPackages,Authentication,RelatedContents]&$lang=en&callback=Get42ContentInfo_JqueryCallBack' | perl -pe 's/.*BroadcastDate":"(.*)","BroadcastTime.*ContentPackages":\[{"Id":(\d+).*/$2_$1/'`
	NUM2=`echo $NUM2_DATE | awk -F "_" '{print $1}'`
	DATE=`echo $NUM2_DATE | awk -F "_" '{print $2}'`
	if [ -e "$DIR/${DATE}_$NAME.mp4" ]; then
		continue;
	fi
	echo -n "Downloading $DATE $NAME..."
	mkdir $DIR/$NUM1
	curl  -s --globoff 'http://capi.9c9media.com/destinations/tsn_web/platforms/desktop/contents/'$NUM1'/contentpackages/'$NUM2'/stacks/?callback=Get42Stacks_JqueryCallBack' | perl -pe 's/Id":/\n/g' | grep -v Get42Stacks | awk -F ',' '{print $1}' | while read NUM3; do
		php $ADOBEHDS --quality high --manifest "http://capi.9c9media.com/destinations/tsn_web/platforms/desktop/contents/$NUM1/contentpackages/$NUM2/stacks/$NUM3/manifest.f4m" --outdir $DIR/$NUM1 > /dev/null
	done
	cd $DIR/$NUM1
	IN=""
	for FILE in `ls *.flv`; do
		mkfifo $FILE.mp4concatpipe
		avconv -loglevel "quiet" -i "$FILE"  -f mpegts -c copy -bsf h264_mp4toannexb -y $FILE.mp4concatpipe &
		IN=$IN\|$FILE.mp4concatpipe
	done
	IN=${IN#\|}
	avconv -loglevel "quiet" -i concat:$IN -c copy $DIR/${DATE}_$NAME.mp4
	rm $DIR/$NUM1/*.mp4concatpipe

	if [ -e "$DIR/${DATE}_$NAME.mp4" ]; then
		chgrp media $DIR/${DATE}_$NAME.mp4
		rm -r $DIR/$NUM1
		echo "Completed";
		continue;
	fi
	echo "Failed"
done
