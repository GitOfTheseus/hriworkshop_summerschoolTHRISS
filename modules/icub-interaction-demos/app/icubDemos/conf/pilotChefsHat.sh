#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Laura Triglia
# email:  laura.triglia@iit.it
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

# Eventually include other scripts using the aboslute path. IN THIS WAY YOU INHERIT THOSE FUNCTIONS.
DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
echo sourcing $DEMOS_BASICS
source $DEMOS_BASICS

#######################################################################################
# "MAIN" DEMOS:                                                                       #
#######################################################################################

# PUT HERE YOUR DEMO #
testCiao(){
    speak "ciao"
}

static(){
  # This action moves the robot in a rest position, with both arms slightly forward and with the hands slightly closed.
	echo "ctpq time 2.5 off 0 pos (-30.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 25.0 29.0 12.0 30.0 16.0 35.0 20.0 28.0 35.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 2.5 off 0 pos (-30.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 25.0 29.0 12.0 30.0 16.0 35.0 20.0 28.0 35.0)" | yarp rpc /ctpservice/right_arm/rpc
	echo "abs 0.0 -4.0 0.0" | yarp write ... /iKinGazeCtrl/angles:i
}

pointing(){
    # pointing to the monitor only one time, then rest pose
    echo "ctpq time 3.5 off 0 pos (-50.0 22.0 11.0 20.0 45.0 -5.0 -6.0 -9.0 29.0 18.0 30.0 16.0 35.0 20.0 28.0 35.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.5 off 0 pos (-25.0 19.0 -3.0 15.0 0.0 0.0 0.0 58.0 20.0 18.0 18.0 9.0 10.0 10.0 10.0 10.0)" | yarp rpc /ctpservice/left_arm/rpc
    
    echo "ctpq time 2.5 off 0 pos (-42.5 22.0 11.0 20.0 45.0 -5.0 -6.0 -9.0 29.0 18.0 30.0 16.0 35.0 20.0 28.0 35.0)" | yarp rpc /ctpservice/right_arm/rpc
    	
    echo "abs 0.0 -15.0 0.0" | yarp write ... /iKinGazeCtrl/angles:i
    sleep 6.0
    static
}

#######################################################################################
# "MAIN" FUNCTION: **leave like that**                                                 #
#######################################################################################
list() {
	compgen -A function
}

echo "********************************************************************************"
echo ""

$1 "$2"

if [[ $# -eq 0 ]] ; then 
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi
