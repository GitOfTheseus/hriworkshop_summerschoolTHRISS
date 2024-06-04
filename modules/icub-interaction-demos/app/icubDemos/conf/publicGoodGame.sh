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

close_eyes(){
	echo "S65" | yarp write ... /icub/face/eyelids/raw/in
	
}

open_eyes(){
	echo "S08" | yarp write ... /icub/face/eyelids/raw/in
}

greet_right_arm(){

	echo "ctpq time 2.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
   	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
   	
}

start_pos()
{
	torso_up
	leftArm_home
	rightArm_home
	head_forward
	smile
	sleep 2.0
}



#######################################################################################
# "MAIN" DEMOS:                                                                    #
#######################################################################################
orientamenti()
{
	greet_right_arm
	speak "Ciao orientamenti! Io sono pronto! Vi aspetto! #LAUGH01#"
    	sleep 5.0
    	start_pos

}
intro() {

	speak "Ciao!"
    	sleep 2.0
 
   	greet_right_arm
    	smile && speak "Io sono aicab!"
    	
    	sleep 2.0
    	smile
	
}

thinking1()
{
	neu
	speak "#MMM02#..."
	sleep 1
}

thinking2()
{
	speak "#THROAT02# ... vediamo un po"
	cun
	sleep 4

}

thinking3()  {
	cun
	speak "#MMM02#... un secondo che ci penso"
	sleep 4
}

thinking4()  {
	
	speak "#BREATH01#"
	sleep 1
}


goodbye() {
	smile
  	echo "ctpq time 2.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
   	sleep 2.0 && speak "Grazie per aver giocato con me !"
   	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
   	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    	smile
    	sleep 4.0 && speak "Ci vediamo!"
   	start_pos
    	smile

}

pressKey_left()
{
	echo "ctpq time 2 off 0 pos (-33.3 25.5 25.8 61.0 60.0 17.0 6.5 13.5 58.4 22.5 51.7 0.0 1.1 57.9 153.66 155.0)" | yarp rpc /ctpservice/left_arm/rpc
	head_down
	sleep 1.0


}

pressKey_right()
{
	echo "ctpq time 2 off 0 pos (-33.3 25.5 25.8 61.0 60.0 17.0 6.5 13.5 58.4 22.5 51.7 0.0 1.1 57.9 153.66 155.0)" | yarp rpc /ctpservice/right_arm/rpc
	head_down
	sleep 1.0

}

head_forward()
{
        echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i
}

head_down()
{
        echo "abs 0 -30 0" | yarp write ... /iKinGazeCtrl/angles:i
}

head_right()
{
        echo "abs 20 0 0" | yarp write ... /iKinGazeCtrl/angles:i
}

head_leftClose()
{
        echo "abs -23 0 0" | yarp write ... /iKinGazeCtrl/angles:i
}

head_leftFar()
{
        echo "abs -10 -2 0" | yarp write ... /iKinGazeCtrl/angles:i
}

rightArm_home()
{
	echo "ctpq time 2 off 0 pos (-24.082 34.3 26.9 74.7 -4.5 13.2 -8.2 28.8 9.9 12.3 15.8 10.2 122.6 9.0 99.0 118.5)" | yarp rpc /ctpservice/right_arm/rpc

}

leftArm_home()
{
	echo "ctpq time 2 off 0 pos (-24.082 34.3 26.9 74.7 -4.5 13.2 -8.2 28.8 9.9 12.3 15.8 10.2 122.6 9.0 99.0 118.5)" | yarp rpc /ctpservice/left_arm/rpc

}

torso_up()
{
	echo "ctpq time 2 off 0 pos (-0.01 0.04 3)" | yarp rpc /ctpservice/torso/rpc

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


