#!/bin/bash

guessables="/usr/local/zend/etc /usr/local/zend/gui/config/zs_ui.ini /usr/local/zend/gui/lighttpd/etc /usr/local/zend/php/7.*/etc"

rm -f /usr/local/zend/tmp/ini-*.lst 2>/dev/null

for p in /usr/local/zend/tmp/ini-patches/*.ini; do
	if head -n1 $p | grep '\[guess\]' > /dev/null 2>&1; then
		echo $p >> /usr/local/zend/tmp/ini-gf.lst
	else
		echo $p >> /usr/local/zend/tmp/ini-ff.lst
	fi
done

### Guessed Files
	# creating lists of directives for guessed files
	cat /usr/local/zend/tmp/ini-gf.lst 2>/dev/null | while read gFile; do
		tail -n +3 $gFile 2>/dev/null | grep -E '^\s*(---)*\s*[a-zA-Z0-9]+' | grep -v '\[' >> /usr/local/zend/tmp/ini-g-dir.lst
	done

	cat /usr/local/zend/tmp/ini-g-dir.lst 2>/dev/null | while read gDir; do
		# xargs is here to trim leading and trailing spaces
		gDirKey=$(echo $gDir | cut -d '=' -f 1 | sed 's|---||' | xargs)
		# optimistically assuming that directives will not have regexp side effects
		guessedFiles="$(grep --include=*.ini -lGR "$gDirKey" $guessables 2>/dev/null)"
		echo "$guessedFiles" | while read directiveFile; do
			gDirMode=$(echo $gDir | grep -oE '^\s*---\s*' | grep -oE '\---')
			if [ "$gDirMode" == "---" ]; then
				# commenting out the existing directives (if found)
				sed -ri "s|^\s*($gDirKey.*)\$|;\1|g" "$directiveFile" 2>/dev/null
			else
				# changing existing directives (if found)
				sed -i "s|^\s*$gDirKey.*\$|$gDir|g" "$directiveFile" 2>/dev/null
			fi
		done
	done

### Specific Files
	# iterating over files in the list
	cat /usr/local/zend/tmp/ini-ff.lst 2>/dev/null | while read ff; do
		# checking whether the specified INI file can be written
		iniPath=$(head -1 $ff | grep -oE '\[.*\]' | sed -e 's|\[||' -e 's|\]||' | xargs)
		iniStat="bad"
		if [ -f "$iniPath" ]; then
			iniStat="OK"
		else
			mkdir -p "$(dirname "$iniPath")" 2>/dev/null
			# not checking whether mkdir was necessary or successful
			touch "$iniPath" 2>/dev/null
			if [ $? -eq 0 ]; then
				# if touch worked, that's all we need
				iniStat="new"
			fi
		fi

		if [ "$iniStat" == "bad" ]; then
			echo "The file '$iniPath' can't be found/created/edited"
		elif [ "$iniStat" == "new" ]; then
			# easy - the file is empty, we just dump directives here
			tail -n +3 $ff 2>/dev/null | grep -E '^\s*[a-zA-Z0-9]+' | grep -v '\[' >> "$iniPath"
		elif [ "$iniStat" == "OK" ]; then
			# we don't really need a condition here, just one of these "safe" moods
			tail -n +3 $ff 2>/dev/null | grep -E '^\s*(---)*\s*[a-zA-Z0-9]+' | grep -v '\[' 2>/dev/null | while read fDir; do
				fDirMode=$(echo $fDir | grep -oE '^\s*---\s*' | grep -oE '\---')
				fDirKey="$(echo $fDir | cut -d '=' -f 1 | sed 's|---||' | xargs)"
				if [ "$fDirMode" == "---" ]; then
					# commenting out the existing directives, that's it
					sed -ri "s|^\s*($fDirKey.*)\$|;\1|g" "$iniPath" 2>/dev/null
				elif grep -E "^\s*$fDirKey" "$iniPath" > /dev/null 2>&1; then
					# the directive exists in the file and is not commented, replacing
					sed -i "s|^\s*$fDirKey.*\$|$fDir|g" "$iniPath" 2>/dev/null
				else
					# the directive doesn't exists and it's not --- (a comment)
					# just adding at the end of the file (+ a line break)
					echo >> "$iniPath"
					echo "$fDir" >> "$iniPath"
				fi
			done
		fi
	done

# we could also clean up at the end,
# but that  is inconvenient for testing
# and a little paranoid, especially in Docker
# rm -f /usr/local/zend/tmp/ini-*.lst
