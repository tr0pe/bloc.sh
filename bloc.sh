#!/bin/sh

. "$(dirname "`command -v "$0"`")/config"

mkdir -p $NOTES_FOLDER

if [ -z "$1" ]; then
	FILE=$NOTES_FOLDER/`date +%Y-%m-%d_%H-%M-%S`
	$EDITOR "$FILE"
	if [ ! -f "$FILE" ]; then
		exit
	fi 
	echo -n "Enter a title for note: "
	read -r TITLE

	while [ 1 ]; do
		if echo "$TITLE" | grep -q "/"; then
			echo -n "Enter a valid title for note: "
			read TITLE
		elif echo "$TITLE" | grep -q "\]"; then
			echo -n "Enter a valid title for note: "
			read TITLE
		elif echo "$TITLE" | grep -q "\["; then
			echo -n "Enter a valid title for note: "
			read TITLE
		else
			break
		fi
	done

	echo -n "     `find $NOTES_FOLDER -type f | wc -l` "
	if [ -z "$TITLE" ]; then
		TITLE="untitled"
	fi

	mv "$FILE" "$FILE [ $TITLE ]"
	basename "$FILE [ $TITLE ]"

	exit
fi

if [ $1 = '-L' ]; then
	$EDITOR "`find $NOTES_FOLDER -type f | sort -n | tail -n 1`"
elif [ $1 = '-l' ]; then
	if [ `tput lines` -gt `find $NOTES_FOLDER -type f | wc -l` ]; then
		find $NOTES_FOLDER -type f | sort -n | sed -e s#"$NOTES_FOLDER/"#""#g | nl
	else
		find $NOTES_FOLDER -type f | sort -n | sed -e s#"$NOTES_FOLDER/"#""#g | nl | less
	fi
elif [ $1 = '-o' ]; then
	if [ $# != "2" ]; then
		echo '-o' option expects an arguments
		exit
	fi

	if echo $2 | grep -q '[[:alpha:]]' || [ -z "$2" ]; then
		echo "Invalid number"
		exit
	fi

	NUM=`find $NOTES_FOLDER -type f | wc -l`
	if [ $2 -gt  $NUM ] || [ $2 -lt "1" ]; then
		echo "Invalid index"
		exit
	fi
	$EDITOR "`find $NOTES_FOLDER -type f | sort -n | head -n $2 | tail -n 1`"
elif [ $1 = '-d' ]; then
	if [ $# != "2" ]; then
		echo "'-d' option expects an argument"
		exit
	fi

	if echo $2 | grep -q '[[:alpha:]]' || [ -z "$2" ]; then
		echo "Invalid number"
		exit
	fi

	NUM=`find $NOTES_FOLDER -type f | wc -l`
	if [ $2 -gt  $NUM ] || [ $2 -lt "1" ]; then
		echo "Invalid index"
		exit
	fi

	FILE=`find $NOTES_FOLDER -type f | sort -n | head -n $2 | tail -n 1`
	echo -n "Delete `basename "$FILE"` ? [y/N] "
	read DEL
	if [ -z "$DEL" ]; then
		exit
	fi
	while [ "$DEL" != 'y' ] && [ "$DEL" != 'n' ]; do
		echo -n "Delete `basename "$FILE"` ? [y/N] "
		read DEL
	done
	if [ "$DEL" = 'y' ]; then
		rm "$FILE"
		echo "Deleted"
	fi
elif [ $1 = '-r' ]; then
	if [ $# != "3" ]; then
		echo "'-r' option expects two arguments"
		exit
	fi

	if echo $2 | grep -q '[[:alpha:]]' || [ -z "$2" ]; then
		echo "Invalid number"
		exit
	fi

	NUM=`find $NOTES_FOLDER -type f | wc -l`
	if [ $2 -gt  $NUM ] || [ $2 -lt "1" ]; then
		echo "Invalid index"
		exit
	fi
	if echo "$3" | grep -q '/'; then
		echo -n "Invalid title"
		exit
	elif echo "$3" | grep -q "\]"; then
		echo -n "Invalid title"
		exit
	elif echo "$3" | grep -q "\["; then
		echo -n "Invalid title"
		exit
	fi
	FILE=`find $NOTES_FOLDER -type f | sort -n | head -n $2 | tail -n 1`
	mv "$FILE" "`echo $FILE | sed "s/\[.*\]/[ $3 ]/g"`"
	basename "`find $NOTES_FOLDER -type f | sort -n | head -n $2 | tail -n 1`"
elif [ $1 = '-n' ]; then
	if [ $# != "2" ]; then
		echo "-n expects an argument"
		exit
	fi
	FILE=$NOTES_FOLDER/`date +%Y-%m-%d_%H-%M-%S`
	if echo "$2" | grep -q '/'; then
		echo "Invalid title"
		exit
	elif echo "$2" | grep -q "\]"; then
		echo "Invalid title"
		exit
	elif echo "$2" | grep -q "\["; then
		echo "Invalid title"
		exit
	fi
	$EDITOR "$FILE [ $2 ]"
	if [ -f "$FILE [ $2 ]" ]; then
		basename "$FILE [ $2 ]"
	fi

elif [ $1 = '-p' ]; then
	if [ $# != "2" ]; then
		echo "-p expects an argument"
		exit 1
	fi

	FILE=`find $NOTES_FOLDER -type f | sort -n | head -n $2 | tail -n 1`
	cat "$FILE"
elif [ $1 = '-h' ]; then
	echo "bloc.sh: Simplest note manager"
	echo " Notes directory: $NOTES_FOLDER"
	echo " Editor: $EDITOR"
	echo " Format: YYYY-MM-DD_HH-MM-SS [ TITLE ]"
	echo " Options:"
	echo "  -l                     List notes"
	echo "  -o [index]             Open note"
	echo "  -d [index]             Delete note"
	echo "  -n [title]             Set note title"
	echo "  -L                     Open last note"
	echo "  -r [index] [title]     Rename note"
	echo "  -h                     Show this message"
	echo "  -p [index]             Show note content"
else
	echo "Invalid option"
fi
