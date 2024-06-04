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

bodybuilder2(){

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

p1(){
    go_home_human
    neutral
}

p2(){
    neutral
    look_person_right
}

p3(){
    smile
    look_person_left
}

p4(){
    look_person_right
}

p5(){
    cun2
    sleep 1.0
    look_person_door
    sleep 1.5
    smile
}

p6(){
    saluta_door
}

cun2() {
    echo "set mou neu" | yarp rpc /icub/face/emotions/in
    echo "set reb cun" | yarp rpc /icub/face/emotions/in
    echo "set leb sad" | yarp rpc /icub/face/emotions/in
}

look_person_left(){
    #breathers "stop"
    echo "ctpq time 1.0 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
    echo "abs -20 20 0" | yarp write ... /iKinGazeCtrl/angles:i 
    #breathers "start"   
}

look_person_right(){
    #breathers "stop"
    echo "ctpq time 1.0 off 0 pos (8.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
    echo "abs 40 10 0" | yarp write ... /iKinGazeCtrl/angles:i
    #breathers "start" 
}

look_person_door(){
    #breathers "stop"
    echo "ctpq time 1 off 0 pos (-17.0 -5.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
    echo "abs -50 8 0" | yarp write ... /iKinGazeCtrl/angles:i
    
    #breathers "start" 
}

saluta_door() {
    #breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 12.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.0 && speak "Ciaoo Lorenzo! Benvenuto!"
    #sleep 2.0 && speak "Hello, my name is aikub, nice to meet you"
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 12.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5    
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 12.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    #smile
    #sleep 1.0
    smile
    echo "ctpq time 2.0 off 0 pos (-1.4 15.8 16.0 15.0 -19.8 -0.32 -9.1 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    
    # "start" 

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

