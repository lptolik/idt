#!/bin/bash

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-htv] [MESSAGE]...
Create blog with header MESSAGE and timestamp.

    -h          display this help and exit
    -t			create blog template and open TextWrangler
    -v			create blog template and open vim
EOF
}

EDITOR='N'
while getopts "htv:" opt; do
	case $opt in
		h)
			show_help
			exit 0
			;;
		v)  EDITOR=$opt
			;;
		t)  EDITOR=$opt
			;;
		*)
			show_help >&2
			exit 1
			;;
	esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --

# Everything that's left in "$@" is a non-option.  In our case, a FILE to process.

fname=""
string=""
for a in "$@" # Loop over arguments
do
	if [[ "${a:0:1}" != "-" ]] # Ignore flags (first character is -)
	then
		if [[ "$string" != "" ]]
		then
			string+=" " # Delimeter
			fname+="_" # Delimeter
		fi
		string+="$a"
		fname+="$a"
	fi
done
echo "$string"

fname+=".txt"
fname=`echo $fname|sed 'y/абвгджзийклмнопрстуфхыэе/abvgdjzijklmnoprstufhyee/'|sed 's/[ьъ]//g; s/ё/yo/g; s/ц/ts/g; s/ч/ch/g; s/ш/sh/g; s/щ/sh/g; s/ю/yu/g; s/я/ya/g'`; 
fname=`echo $fname|sed 'y/АБВГДЖЗИЙКЛМНОПРСТУФХЫЭЕ/ABVGDJZIJKLMNOPRSTUFHYEE/'|sed 's/[ЬЪ]//g; s/Ё/YO/g; s/Ц/TS/g; s/Ч/CH/g; s/Ш/SH/g; s/Щ/SH/g; s/Ю/YU/g; s/Я/YA/g'`; 
fname=`echo "${fname}" | tr '[A-Z]' '[a-z]'`


DIR='/Users/lptolik/Documents/Projects/Plans/dokuwiki/idonethis'

rDIR=$PWD
cd $DIR

if [[ $(git status -s) ]]
then
    echo "The idonethis directory is dirty. Please commit any pending changes."
    exit 1;
fi

printf "====== $string ======\n\n\n" > $fname
printf "%s\n" "---" "$(date '+%F %T')" " " "{{tag>IDT blog $(date +%Y) $(date +%B)}}" >> $fname

case $EDITOR in
	v)  vim "$fname"
		;;
	t)  otw "$fname"
		;;
	*)
		;;
esac
git pull
git add $fname
git commit -m "' blog $(date '+%F %T')'"
git push
cd $rDIR
