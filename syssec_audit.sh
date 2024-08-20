#! /bin/bash

# Verify if user is root before executing this script.
	if [ ! "$UID" = "0" ]; then
	 echo "You must be root to run this script."
	 exit 1
	fi


# Verify if no option has been passed. 
	if [ "$*" = "" ]; then
	 $0 -h
	 exit 1
	fi


# Verify if our working directory exist.
     	if [ ! -d /var/log/acad ] 
   	 then
	 mkdir /var/log/acad 
  	 echo "warning: /var/log/acad created."
	fi


###############
# Development #
###############


# Eye candy.
function show_progress() {
	
	echo -en "\e7\e[K$1\e8"

}


# Compares and sort new lines.
function getnewlines() {

	(cat /var/log/acad/$filename /var/log/acad/$filename.old | sort | uniq -u; cat /var/log/acad/$filename) | sort | uniq -d

}

# Confirm if either any new or removed file has being added/removed in the database.
function chkfiles() {

	if [ "$(getnewlines /var/log/acad/$filename /var/log/acad/$filename.old)" = "" ]; then
	 echo "No new or removed $filename files found."; else
	 echo "New or removed $filename files found:"
	 getnewlines $filename $filename.old
	 echo
	fi

}


# Find most hidden files. 
function listhidden() {

	[ -r /var/log/acad/hidden_files ] && mv /var/log/acad/hidden_files /var/log/acad/hidden_files.old
 	 find / -name "...*" -print > /var/log/acad/hidden_files
	 find / -name "..." -print >> /var/log/acad/hidden_files
	 find / -name "... " -print >> /var/log/acad/hidden_files
	 find / -name ".. " -print >> /var/log/acad/hidden_files
	 find / -name ". " -print >> /var/log/acad/hidden_files

}


# Find all SGID files.
function listsgid() {

        if [ -r /var/log/acad/sgid ]; then
	 mv /var/log/acad/sgid /var/log/acad/sgid.old
       	 find / -perm -2000 -type f -print > /var/log/acad/sgid; else
         find / -perm -2000 -type f -print > /var/log/acad/sgid
        fi

}


# Find all SUID files.
function listsuid() {

        [ -r /var/log/acad/suid ] && mv /var/log/acad/suid /var/log/acad/suid.old
        find / \( -perm -004000 \) -type f -print > /var/log/acad/suid

}


function listmd5() {

	if [ -r /var/log/acad/md5sum ]; then
	 mv /var/log/acad/md5sum /var/log/acad/md5sum.old
	fi
	
	echo -en "Processing: "
	
	 find $(echo ${PATH} | tr ':' ' ') -type f | while read FILE ; do
  	  show_progress "$FILE"
         echo "`md5sum "$FILE"` `ls -l "$FILE" | awk '{print $1,$3,$4,$5,$6,$7,$8}'`" >> "/var/log/acad/md5sum"
 done

}


# Defeat backdoored/trojaned md5sum if used correctly.
function chkmd5sum() {

	for ufile in `(cat /var/log/acad/$filename /var/log/acad/$filename.old | sort | uniq -u; cat /var/log/acad/$filename) | sort | uniq -d | awk '{print $2 }'`; do
	diffn=`cat /var/log/acad/$filename | grep $ufile`
	diffo=`cat /var/log/acad/$filename.old | grep $ufile`

		md5sumn=`echo $diffn | awk '{print $1}'`
		md5sumo=`echo $diffo | awk '{print $1}'`

		permn=`echo $diffn | awk '{print $3}'`
		permo=`echo $diffo | awk '{print $3}'`

		ownern=`echo $diffn | awk '{print $4}'`
		ownero=`echo $diffo | awk '{print $4}'`

		fsizen=`echo $diffn | awk '{print $5}'`
		fsizeo=`echo $diffo | awk '{print $5}'`
		daten=`echo $diffn | awk '{print $7,$8,$9}'`
		dateo=`echo $diffo | awk '{print $7,$8,$9}'`


			if [ ! "$md5sumn" = "$md5sumo" ] &&
		       	 [ ! "$md5sumn" = "" ] &&
			 [ ! "$md5sumo" = "" ]; then
				echo "The md5sum of $ufile has being altered."
				echo "The current md5sum is $md5sumn"
				echo "and was $md5sumo."
				echo
			fi

			if [ ! "$permn" = "$permo" ] &&
			 [ ! "$permn" = "" ] &&
			 [ ! "$permo" = "" ]; then
				echo "The permission of $ufile has being changed."
				echo "$ufile was $permo and is now $permn."
				echo
			fi

			if [ ! "$ownern" = "$ownero" ] &&
			 [ ! "$ownern" = "" ] &&
			 [ ! "$ownero" = "" ]; then
				echo "The owner of $ufile was $ownero."
				echo
			fi

			if [ ! "$fsizen" = "$fsizeo" ] &&
	 		 [ ! "$fsizen" = "" ] &&
			 [ ! "$fsizeo" = "" ]; then
				echo "The size of $ufile was $fsizeo and is now fsizen."
				echo
			fi

			if [ ! "$daten" = "$dateo" ] &&
			 [ ! "$daten" = "" ] &&
			 [ ! "$dateo" = "" ]; then
				echo "The date of creation of $ufile has being changed."
				echo "It was \"$daten\" and is now \"$dateo\"."
			fi
	done

}


# Find all unowned files.
function listunowned() {

	[ -r /var/log/acad/unowned ] && mv /var/log/acad/unowned /var/log/acad/unowned.old
	find / -nouser -o -nogroup > /var/log/acad/unowned

}


# Find all world writable files.
function listworldwritable() {

	[ -r /var/log/acad/worldwritable ] && mv /var/log/acad/worldwritable /var/log/acad/worldwritable.old
	find / -perm -2 ! -type l -ls > /var/log/acad/worldwritable

}


# Email notification management.
function mailer() {

	email=$OPTARG

	if [ ! $EMAIL = "" ]; then
	 e=1
	fi

}


# If this is the first time acad is ran using this option(s) dont try to
# compare with the old list as it's not existing.
function ifnewlist() {

        if [ ! -r /var/log/acad/$filename.old ]; then
         echo "The $filename list has being created successfully."
         exit 0
        fi

}


# Option verification. 
function check_args() {

	while getopts ":e:fghmsuw" option; do
	 [[ "$option" == ":" ]] && 
	  echo "Usage: $0 [-fghmsuw] [-e <email>]" &&
	  echo "Try \`$0 -h' for help." &&
	 exit 1
        done
}


# Option management using the advanced function getopts.
function call_args() {

         OPTIND=1

         while getopts "e:fghmsuw" option; do
		case $option in

# Verify if the user wants to receive the auditing results by email.
e)
	mailer
      ;;


# List hidden files and directories.
f)
        listhidden
         filename=hidden_files

	ifnewlist
         chkfiles
      ;;


# List sgid files.
g)
        listsgid
         filename=sgid

	ifnewlist
         chkfiles
      ;;


# Print the help (-h) option.
h)
echo "acad, version beta 3"
echo
echo "Usage: acad [-fghmsuw] [-e <email>]"
echo
echo "  e : send auditing results by mail"
echo "  f : find all hidden files"
echo "  g : find all sgid files"
echo "  h : print this message"
echo "  m : listall md5sum"
echo "  s : find all suid files"
echo "  u : find all unowned files"
echo "  w : find all world writable files"
;;


# Verify md5sums.
m)
        listmd5
         filename=md5sum

	ifnewlist
         chkmd5sum
      ;;


# List suid files.
s)
        listsuid
         filename=suid

 	ifnewlist
         chkfiles
      ;;


# List unowned files.
u)
        listunowned
         filename=unowned

	ifnewlist
         chkfiles
      ;;


# List world writable files.
w)
        listworldwritable
         filename=worldwritable

	ifnewlist
         chkfiles
      ;;

        esac
done

}

# Verify if all arguments (options) are correctly used.
check_args $*

# Call $0 ${n}
call_args $*


