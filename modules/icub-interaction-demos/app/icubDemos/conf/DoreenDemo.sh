#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2022 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Giulia Scorza Azzarà, Giulia Pusceddu
# email:  giulia.scorza@iit.it, giulia.pusceddu@iit.it
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
# GENERAL FUNCTIONS:                                                                  #
#######################################################################################
prova(){
speak "I want to kill you"
}
rest() {
	neutral
	echo "ctpq time 2.0 off 0 pos (-3.0 18.5 10.0 22.0 0.0 10.0 0.00 44.5 28.0 38.0 0.0 0.0 20.0 0.0 14.0 13.5)" | yarp rpc /ctpservice/left_arm/rpc 
	echo "ctpq time 2.0 off 0 pos (-3.0 14.5 14.5 24.5 10.0 18.0 0.0 25.0 23.0 50.0 0.0 0.0 30.5 0.0 27.5 35.0)" | yarp rpc /ctpservice/right_arm/rpc 
	echo "ctpq time 2.0 off 0 pos (0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc 
	echo "ctpq time 2.0 off 0 pos (0.0 0.0 0.0)" | yarp rpc /ctpservice/torso/rpc 
}

turn() {
	echo "ctpq time $1 off 0 pos (-2.0 2.0 -35.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc 
	echo "ctpq time $1 off 0 pos (42.0 0.0 10.0)" | yarp rpc /ctpservice/torso/rpc 
}

look_left() {
	echo "ctpq time 1.5 off 0 pos (0.0 0.0 20.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
	echo "ctpq time 1.5 off 0 pos (0.0 0.0 -20.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
}

look_right() {
	echo "ctpq time 1.5 off 0 pos (0.0 0.0 -20.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
	echo "ctpq time 1.5 off 0 pos (0.0 0.0 20.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
}

look_down() {
	echo "ctpq time 2.0 off 0 pos (-15.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
}

torso_down() {
	echo "ctpq time 1.0 off 0 pos (0.0 0.0 10.0)" | yarp rpc /ctpservice/torso/rpc 
	echo "ctpq time 2.0 off 0 pos (6.0 17.5 17.0 22.0 -15.0 10.0 0.00 44.5 28.0 50.0 0.0 0.0 20.0 0.0 14.0 13.5)" | yarp rpc /ctpservice/left_arm/rpc 
	echo "ctpq time 2.0 off 0 pos (6.0 17.5 17.0 24.5 -10.0 18.0 0.0 25.0 23.0 50.0 0.0 0.0 30.5 0.0 27.5 35.0)" | yarp rpc /ctpservice/right_arm/rpc 
}

greet() {
   	echo "ctpq time 2.0 off 0 pos (-60.0 44.0 -2.0 96.0 0.0 -17.0 10.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
   	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 0.0 -17.0 25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 0.0 -17.0 -5.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc  
	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 0.0 -17.0 25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 0.0 -17.0 -5.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
}

point_left(){
	echo "ctpq time 2.0 off 0 pos (-56.0 21.0 31.0 49.0 45.5 2.0 5.6 34.8 40.0 7.7 86.0 0.0 0.0 38.8 145.0 180.0)" | yarp rpc /ctpservice/left_arm/rpc 	
}


#######################################################################################
# INTROVERT: kenny voice                                                              #
#######################################################################################

e1_int() {
	turn 3.0
	sleep 3.0
	speak "Hello"
	sleep 1.0
	rest
	breathers "start"	
}

e2_int() {
	breathers "stop"
	turn 3.0
	sleep 3.0
	speak "I think this may take a while"
	sleep 2.0
	rest
	breathers "start"
	
}

e3_int() {
	# neutral state
	breathers "stop"
	look_down
	rest
	breathers "start"
}

e4_int() {
	breathers "stop"
	turn 3.0
	sleep 3.0
	speak "The streets are full today"
	sleep 2.0
	rest
	breathers "start"
}

e5_int() {
	# neutral state
	breathers "stop"
	look_right
	rest
	breathers "start"
}

e6_int() {
	breathers "stop"
	turn 3.0
	sleep 3.0
	speak "Again, we are waiting"
	sleep 2.0
	rest
	breathers "start"
}

e7_int() {
	breathers "stop"
	turn 3.0
	sleep 3.0
	speak "It``s raining. Be careful"
	sleep 3.0
	rest
	breathers "start"
}

e8_int() {
	# neutral state
	breathers "stop"
	look_left
	rest
	breathers "start"
}

e9_int() {
	breathers "stop"
	turn 3.0
	sleep 3.0
	speak "Thank you for your participation. Goodbye."
	sleep 4.0
	rest
}


#######################################################################################
# EXTROVERT: josh voice                                                               #
#######################################################################################

e1_ext() {
	smile
	turn 2.0
	sleep 2.0
	greet
	sleep 2.0
	speak "Hello, welcome to the experiment. I am i Cub."
	sleep 4.0
	rest
	breathers "start"
}

e2_ext() {
	breathers "stop"
	sad
	turn 2.0
	sleep 2.0
	speak "Oh no! It``s red. I dont like to wait"
	sleep 3.0
	rest
	sad
	breathers "start"
}

e3_ext() {
	breathers "stop"
	surprised
	look_down
	torso_down
	sleep 2.0
	speak "Hey!"
	rest
	sleep 1.0
	turn 2.0
	sleep 2.0
	speak "What is happening here?"
	sleep 2.0
	rest
	breathers "start"
}

e4_ext() {
	breathers "stop"
	sad
	look_left
	sleep 2.0
	speak "Hey guys! Walk away"
	sleep 2.5
	rest
	breathers "start"
}

e5_ext() {
	breathers "stop"
	turn 2.0
	sleep 1.0
	point_left
	sleep 1.5
	speak "Attention!"
	sleep 2.0
	rest
	breathers "start"
}

e6_ext() {
	breathers "stop"
	smile
	turn 2.0
	sleep 2.0
	speak "Time for another break, I guess"
	sleep 2.0
	rest
	breathers "start"
}

e7_ext() {
	breathers "stop"
	turn 2.0
	sleep 2.0
	speak "Uhh, it``s raining. Do you like rain?"
	sleep 4.0
	rest
	breathers "start"
}

e8_ext() {
	breathers "stop"
	smile
	turn 2.0
	sleep 2.0
	speak "You can master it"
	sleep 1.0
	rest
	breathers "start"
}

e9_ext() {
	breathers "stop"
	smile
	turn 2.0
	sleep 2.0
	speak "You did a great job. Thank you so much, have a nice day!"
	greet_with_left_thumb_up 
	sleep 2.0
	rest
	smile
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

