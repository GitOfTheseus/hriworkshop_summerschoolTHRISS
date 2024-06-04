#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  
# email:  
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

#######################################################################################
# ICUB SPEECH AND MOVEMENTS FOR WRITE ON MY SKIN DEMO:                                                        #
#######################################################################################


# include icub_basics

DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
echo sourcing $DEMOS_BASICS
source $DEMOS_BASICS

#######################################################################################
# MAIN FUNCTIONS:                                                                    #
#######################################################################################


start_pos(){
	echo "ctpq time 2.5 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" |  yarp rpc /ctpservice/left_arm/rpc
    	echo "ctpq time 2.5 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" |  yarp rpc /ctpservice/right_arm/rpc
}
#######################################################################################
# "MAIN" DEMOS:                                                                    #10.0.0.255
#######################################################################################
intro() {

	speak "hello Everyone!happy to see you all"
    	sleep 2.0
 
    	smile && speak "welcome to our optical center !"
    	
    	sleep 2.0
   	start_pos
    	smile
	
}


speaker_command1(){
	speak "participant A asks participant B"
	sleep 2.0
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i
}
speaker_command2(){
	speak "participant B asks participant C"
	sleep 2.0
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i
}
speaker_command3(){
	speak "participant C asks participant B"
	sleep 2.0
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i
}


Grabbing_Posing_cube(){
	speak "all participants can you grab and pose your cubes in front of you?"
}

Thank_You(){
	speak "Thank you! now we can proceed"
}




#######################################################################################
# "MAIN" FUNCTION:                                                                    #
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


