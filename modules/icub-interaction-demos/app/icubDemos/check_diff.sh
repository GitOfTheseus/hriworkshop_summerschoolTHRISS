#!/bin/bash
IS_DEST=1
IS_CONF=1

DEST_FOLDER=""
IS_SAFE=1
RED=$(tput setaf 1)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)

#echo "Checking if it is safe to install the new scripts"
#echo "..."

for var in "$@"
do
    if [ $IS_DEST == 0 -a $IS_CONF == 1 ]; then        
        DEST_FOLDER=$var
        #echo "Dest folder is $var"
        IS_DEST=1
    fi

    if [ $IS_CONF == 0 -a $IS_DEST == 1 ]; then        
        a=($(echo "$var" | tr '/' '\n'))
        f=$DEST_FOLDER/${a[-1]}

        if test -f "$f"; then
            res=`diff -q $var $f`
            if [ ! -z "$res" ]; then
                #echo "${RED}$res${NORMAL}"
                #echo "${RED}Please review the differences before installing${NORMAL}"
                meld $var $f
                #echo ""
                IS_SAFE=0
            fi
        fi        
    fi

    if [ $IS_DEST == 1 -a "--dest" == $var ]; then
        IS_DEST=0
        #echo "Next arg is the destination"
    fi

    if [ $IS_CONF == 1 -a "--conf" == $var ]; then
        IS_DEST=1
        IS_CONF=0
        #echo "Next arg is a bash script to check"
    fi
done
#echo "..."
#if [ $IS_SAFE == 0 ]; then
#    printf 'Continue to Install (y/n)? '
#    read answer
#    if [ "$answer" != "${answer#[Yy]}" ] ;then
#        echo "${GREEN}Start Installing${NORMAL}"
#        IS_SAFE=1
#    else
#        echo "${RED}Stop Installing${NORMAL}"
#        IS_SAFE=0
#    fi
#else
#    echo "${GREEN}Start Installing${NORMAL}"
#fi


exit $IS_SAFE