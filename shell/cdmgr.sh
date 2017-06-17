#! /bin/sh

menu_choice=""
current_cd=""
title_file="title.cdb"
tracks_file="tracks.cdb"
temp_file=/tmp/cdb.$$
trap 'rm -f $temp_file' EXIT

get_return(){
    echo -e "Press return \c"
    read x
    return 0
}

get_confirm(){
    echo -e "Are you sure? \c"
    while true
    do
	read x
	case "$x" in
	    y|yes|Y|Yes|YES)
		return 0;;
	    n|no|N|No|NO)
		echo
		echo "Cancelled"
		return 1;;
	    *)
		echo "Please enter yes or no"
		esac
	done
}


set_menu_choice(){
    clear
    echo "Options :-"
    echo
    echo " a) Add new CD"
    echo " f) Find CD"
    echo " c) Count the CDs and tracks in the catalog"
    if [ "$cdcatnum" !="" ]; then
	echo " l) List tracks on $cdtitle"
	echo " r) Remove $cdtitle"
	echo " u) Update track information for $cdtitle"
    fi
    echo " q) Quit"
    echo 
    echo -e "Please enter choice then press return \c"
    read menu_choice
    return
}

insert_title(){
    echo $* >> $title_file
    return
}

insert_track(){
    echo $* >> $tracks_file
    return
}

add_record_tracks(){
    echo "Enter track informatin for this CD"
    echo "When no more tracks enter q"
    cdtrack=1
    cdttitle=""
    while [ "$cdttile" !="q" ]
    do
	echo -e "Track $cdtrack,track title? \c"
	read tmp
	cdttitle=${tmp%%,*}
	if [ "$tmp" !="$cdttitle"]; then
	    echo "Sorry,no commas allowed"
	    continue
	fi
	if [ -n "$cdttitle" ]; then
	    if ["$cdttitle"!="q"]; then
		insert_track $cdcatnum,$cdtrack,$cdttitle
	    fi
	 else
	    cdtrack=$((cdtrack-1))
	fi
	cdtrack=$((cdtrack+1))
     done
}