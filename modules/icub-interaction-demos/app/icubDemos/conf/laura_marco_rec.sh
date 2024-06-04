#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Francesco Rea
# email:  francesco.rea@iit.it
# Permission is granted to copy, distribute, and/or modify this program
# under the terms of the GNU General Public License, version 2 or any
# later version published by the Free Software Foundation.
#  *
# A copy of the license can be found at
# http://www.robotcub.org/icub/license/gpl.txt
#  *
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details
#######################################################################################

DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
echo sourcing $DEMOS_BASICS
source $DEMOS_BASICS

#######################################################################################
# USEFUL FUNCTIONS:                                                                  #
#######################################################################################
usage() {
cat << EOF
***************************************************************************************
DEA SCRIPTING
Author:  Alessandro Roncone   <alessandro.roncone@iit.it> 

This script scripts through the commands available for the DeA Kids videos.

USAGE:
        $0 options

***************************************************************************************
OPTIONS:

***************************************************************************************
EXAMPLE USAGE:

***************************************************************************************
EOF
}

#######################################################################################
# FUNCTIONS:                                                                         #
#######################################################################################

pointing_right() {
	echo "ctpq time 2 off 0 pos (-33.3 25.5 25.8 61.0 60.0 17.0 6.5 13.5 58.4 22.5 51.7 0.0 1.1 57.9 153.66 155.0)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 1.0
}

return_right() {
	echo "ctpq time 2.0 off 0 pos (-4.4 13.9 15.02 22.7 -6.7 -8.8 1.4 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 1.0
}

look_mate() {
        echo "abs 50 0 0" | yarp write ... /iKinGazeCtrl/angles:i
	sleep 1.0
}

look_screen() {
        echo "abs 0 -20 0" | yarp write ... /iKinGazeCtrl/angles:i
	sleep 1.0
}

smile() {
    	echo "set all hap" | yarp rpc /icub/face/emotions/in
	sleep 1.0
}

neu() {
	echo "set all neu" | yarp rpc /icub/face/emotions/in
	sleep 1.0
}

start_recording() {
	go_home_human
	sleep 2.0
	neu
	look_screen
	sleep 3.0	
	look_mate
	neu
	sleep 3.0
	look_screen
	pointing_right
	sleep 3.0
	return_right
	neu
	look_screen
	sleep 5.0
	look_mate
	sleep 2.0
	smile
}


#######################################################################################
# "MAIN" FUNCTION:                                                                    #
#######################################################################################
echo "********************************************************************************"
echo ""

$1 "$2"

if [[ $# -eq 0 ]] ; then 
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi

