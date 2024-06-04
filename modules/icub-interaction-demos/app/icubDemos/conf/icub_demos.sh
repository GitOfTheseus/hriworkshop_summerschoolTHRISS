#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Francesco Rea, Gonzalez Jonas, Dario Pasquali
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
DEMOS_CROCODILE=$(yarp resource --context icubDemos --find icub_crocodile_dance.sh | grep -v 'DEBUG' | tr -d '"')

echo sourcing $DEMOS_BASICS
echo sourcing $DEMOS_CROCODILE 
source $DEMOS_BASICS
source $DEMOS_CROCODILE
#######################################################################################
# "MAIN" DEMOS:                                                                    #
#######################################################################################

bodybuilder(){

	mostra_muscoli
	sleep 1.0
	speak "Guarda che muscolih!"
    	right_up_left_down

	sleep 1.0
	speak "Sono tropo figo!"
	left_up_right_down

	sleep 1.0
	opposite_muscles

	sleep 1.0

	go_home

}

iros_demo_left(){
	echo "draw lt" | yarp rpc /demoModule
	sleep 1.0
	look_left
        echo "ctpq time 2 off 0 pos (-29 0 -8)" | yarp rpc /ctpservice/torso/rpc
	saluta
	

	sleep 1.0
        echo "ctpq time 2 off 0 pos (0 0 -8)" | yarp rpc /ctpservice/torso/rpc


}

iros_demo_right(){
	

	echo "draw rt" | yarp rpc /demoModule
	sleep 1.0
	look_right
        echo "ctpq time 2 off 0 pos (29 0 -8)" | yarp rpc /ctpservice/torso/rpc
	saluta_right
	
        echo "del" | yarp rpc /demoModule
	echo "ctpq time 2 off 0 pos (0 0 -8)" | yarp rpc /ctpservice/torso/rpc
}


self_introduction(){
	
	go_home
	sleep 1.0
	speak "Io sono aicab. un robot nato all istituto italiano di tecnologia. "
	sleep 4.0
	speak "Guardate cosa so fare!"
	sleep 2.0
	explain_eyes
	sleep 3.0
	explain_skin_forearm
	sleep 3.0
	present_emotions
	sleep 2.0
	explain_nose	
	go_home

    }


stop_robot(){
	pgrep iKinGazeCtrl | xargs kill
	sleep 1.0
	ssh icub-head 'pgrep yarprobot* | xargs kill'
	sleep 2.0
}

start_robot(){
	ssh icub-head yarprobotinterface > /dev/null 2>&1 &
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

