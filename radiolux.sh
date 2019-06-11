#!/bin/sh
#Daniel McGuinness & Ryan McAleaney 2019

URLMAIN="http://www.umdmusic.com/"
URL="default.asp?Lang=English&Chart=F&ChDate=19800403&ChMode=N"
NEXT="Next Chart"
SONG="<TD STYLE=\"font-size:10pt;font-family:Arial;padding-left:0.1in\">"
OUTFILE="output.txt"
ENDFLAG=0
SILENTFLAG=0

display_help(){
  echo "NAME"
  echo "  radiolux - Uses cURL to retrieve Radio Luxembourg charts from 1980-1991."
  echo ""
  echo "SYNOPSIS"
  echo "  radiolux [OPTIONS]"
  echo ""
  echo "DESCRIPTION"
  echo "  Retrieves weekly chart listings from Ultimate Music Database (http://www.umdmusic.com) and puts them into a ranked text file."
  echo ""
  echo "  -h            Displays the help menu."
  echo "  -o STRING     Sets the file that the chart listings are written, defaults to 'output.txt'."
  echo "  -s            Run the command silently, without any progress bar."
}

while getopts sho: o
do
  case "$o" in
    o)    OUTFILE="${OPTARG}";;
    s)    SILENTFLAG=1;;
    h)    display_help
          exit 0;;
    [?])  display_help
          exit 0;;
  esac
done
shift $((OPTIND-1))

echo "RADIO LUXEMBOURG CHARTS" > "$OUTFILE"
echo "Downloading Charts:"
while [ $ENDFLAG -eq 0 ]; do

  #retrieve HTML webpage
  curl -s -o "website.html" "$URLMAIN$URL"

  #Chart Date parsing
  TIME=$(echo "$URL" | sed "s/default.asp?Lang=English&Chart=F&ChDate=\([[:alnum:]]\{4\}\)\([[:alnum:]]\{2\}\)\([[:alnum:]]\{2\}\)&ChMode=N/\3-\2-\1/g")
  echo "$TIME" >> "$OUTFILE"

  if [ $SILENTFLAG -eq 0 ]; then
    printf "%s / 15-12-1991\r" "$TIME"
  fi


  #Chart songs parsing
  grep -F "$SONG" "website.html" | sed "s/$SONG//g; s/<\/*[[:alnum:]]*>//g; s/[[:space:]]\{2,\}//g; s/\([[:lower:]][[:punct:]]*\)\([[:upper:]]\)/\1\t\2/g; /^?/d; /^-/d" | cat -n >> "$OUTFILE"
  URL=$(grep -F "$NEXT" "website.html" | sed "s/\t<TD ALIGN=\"right\"><A HREF='\(.*\)'><B>Next Chart<\/B>/\1/g; s/\r//g")

  if [ "$URL" = "" ]
  then
    ENDFLAG=1
  fi

done

rm -f website.html

if [ $SILENTFLAG -eq 0 ]; then
  echo
  echo "Done."
fi
