#! /bin/bash

function display
{
	eval $1=1 #we use eval to pass the var by reference
	echo "" > ../display
	for file in `ls`
	do				
		lsof $file 1> /dev/null 2>/dev/null	#check if file is open	
		if [ $? -eq 0 ]
		then
			echo "`ls -lh $file | awk '{printf "%s %s\n",$8,$5}'`"	>> ../display
			eval $1=0
		else
			echo "$file DONE" >> ../display
		fi
	done
	clear
	cat ../display
}

function download_content
{
	WGET_MOD="-o /dev/null -b -q"
	url=$1
	links=$2
	final=0
	touch display #fitxer mostra descarregues
	cd content	
	root=`echo $url | awk '/http:\/\// {print $2 $3}' FS='/'`	
	clear	
	for i in ${links[*]}
	do
		
		#entire url	
		if [[ $i =~ ^https? ]] #either http or https
		then				
			wget $WGET_MOD $i >/dev/null

		#root url
		elif [[ $i =~ ^'/' ]]	#link starts with '/'
		then			
			wget $WGET_MOD http://$root$i >/dev/null

		#partial url
		else
			wget $WGET_MOD $url$i >/dev/null
		fi		
	done	

	echo "`ls -lh | awk '{printf "%s %d\n",$8,$5}'`" 	
	until [ $final -eq 1 ]
	do		
		display final
	done
}

function execute_wget
{
	url=$1
	touch index.html
	wget -O index.html -q $url
	if [ $? -eq 0 ] #execucio correcta del wget
	then
		links=(`cat index.html | grep -E '<a\ href="*"' | awk '/a href/ {print $2}' RS="<" FS='"'`)
		
		test -d "$PWD/content" || mkdir content
		download_content $url $links
		cd ../
		rm index.html #ja ens hem baixat tot el que penja d'ella	
		rm display
	else
		echo "Web doesn't exist"
	fi
}


# MAIN

if [ $# = 1 ]
then	
	execute_wget $1
else
	echo 'incorrect number of parameters'
	echo 'Usage: ./ewget http://my/web/site'
fi

# FINAL