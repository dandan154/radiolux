#Daniel McGuinness & Ryan McAleaney 2019
#!/bin/sh

URLMAIN="http://www.umdmusic.com/"
URL="default.asp?Lang=English&Chart=F&ChDate=19800403&ChMode=N"
NEXT="Next Chart"
SONG="<TD STYLE=\"font-size:10pt;font-family:Arial;padding-left:0.1in\">"
TEST=""
ENDFLAG=0
INC=1

#TODO: Change method by which songs and artists are retrieved, make seperation more distinct before appending to file
#TODO: Ideal system should check start of both song and artist seperately, if either contains a ?-prefix, remove


echo "RADIO LUXEMBOURG CHARTS" > output.txt
echo "Downloading Charts:"
while [ $ENDFLAG -eq 0 ]; do

  #retrieve HTML webpage
  curl -s -o "website.html" "$URLMAIN$URL"

  #Chart Date parsing
  TIME=$(echo $URL | sed "s/default.asp?Lang=English&Chart=F&ChDate=\([[:alnum:]]\{4\}\)\([[:alnum:]]\{2\}\)\([[:alnum:]]\{2\}\)&ChMode=N/\3-\2-\1/g")
  echo $TIME >> output.txt
  echo -ne "$TIME / 15-12-1991\r"

  #Chart songs parsing
  grep -F "$SONG" "website.html" | sed "s/$SONG//g; s/<\/*[[:alnum:]]*>//g; s/[[:space:]]\{2,\}//g; s/\([[:lower:]][[:punct:]]*\)\([[:upper:]]\)/\1\t\2/g; /^?/d; /^-/d" | cat -n >> output.txt
  URL=$(grep -F "$NEXT" "website.html" | sed "s/\t<TD ALIGN=\"right\"><A HREF='\(.*\)'><B>Next Chart<\/B>/\1/g;")
  URL=${URL%$'\r'}


  if [ "$URL" = "" ]
  then
    ENDFLAG=1
  fi

done

rm -f website.html
echo
echo "Done."
