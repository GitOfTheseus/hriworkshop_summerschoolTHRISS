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
echo sourcing $DEMOS_BASICS
source $DEMOS_BASICS


#######################################################################################
# ITALIAN GESTURES:                                                                    #
#######################################################################################

cosavuoi(){ #left

	go_home
	echo "set all cun" | yarp rpc /icub/face/emotions/in
	sleep 1.0
	echo "ctpq time 2.0 off 0 pos (-21.8 27.2 4.0 61.8 -60.0 6.7 -6.9 12.5 66.4 36.0 14.3 36.7 68.0 20.8 97.0 75.6)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.2
	echo "ctpq time 0.4 off 0 pos (-21.8 27.2 4.0 74.0 -60.0 6.7 -6.9 12.5 66.4 36.0 14.3 36.7 68.0 20.8 97.0 75.6)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.2
	echo "ctpq time 0.4 off 0 pos (-21.8 27.2 4.0 61.8 -60.0 6.7 -6.9 12.5 66.4 36.0 14.3 36.7 68.0 20.8 97.0 75.6)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.2
	echo "ctpq time 0.4 off 0 pos (-21.8 27.2 4.0 74.0 -60.0 6.7 -6.9 12.5 66.4 36.0 14.3 36.7 68.0 20.8 97.0 75.6)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.2
	echo "ctpq time 0.4 off 0 pos (-21.8 27.2 4.0 61.8 -60.0 6.7 -6.9 12.5 66.4 36.0 14.3 36.7 68.0 20.8 97.0 75.6)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.2
	echo "ctpq time 0.4 off 0 pos (-21.8 27.2 4.0 74.0 -60.0 6.7 -6.9 12.5 66.4 36.0 14.3 36.7 68.0 20.8 97.0 75.6)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.4
	echo "set all cun" | yarp rpc /icub/face/emotions/in
	go_home
}

cosicosi(){	#left
	go_home
	sleep 1.0
	echo "ctpq time 1.0 off 0 pos (-6.4 30.5 13.4 70.9 -59.9 -0.1 -6.5 12.8 24.8 32.3 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	echo "ctpq time 0.5 off 0 pos (-6.4 30.5 13.4 70.9 -30.0 -0.1 -6.5 12.8 24.8 32.3 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	echo "ctpq time 0.5 off 0 pos (-6.4 30.5 13.4 70.9 -59.9 -0.1 -6.5 12.8 24.8 32.3 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	echo "ctpq time 0.5 off 0 pos (-6.4 30.5 13.4 70.9 -30.0 -0.1 -6.5 12.8 24.8 32.3 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	echo "ctpq time 0.5 off 0 pos (-6.4 30.5 13.4 70.9 -59.9 -0.1 -6.5 12.8 24.8 32.3 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	echo "ctpq time 0.5 off 0 pos (-6.4 30.5 13.4 70.9 -30.0 -0.1 -6.5 12.8 24.8 32.3 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	go_home
}

vieniqui(){
	go_home
	echo "set all cun" | yarp rpc /icub/face/emotions/in
	sleep 1.0
		#dita chiuse pollice aperto
		#echo "ctpq time 1.0 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 18.2 7.4 3.7 6.2 111.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
		#sleep 0.2
	#indice chiuso
	echo "ctpq time 1.0 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 43.2 13.5 30.0 6.2 111.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.3
	#indice steso
	echo "ctpq time 0.6 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 43.2 13.5 30.0 6.2 7.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.5
	#indice chiuso
	echo "ctpq time 0.6 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 43.2 13.5 30.0 6.2 111.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.5
	#indice steso
	echo "ctpq time 0.6 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 43.2 13.5 30.0 6.2 7.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.5
	#indice chiuso
	echo "ctpq time 0.6 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 43.2 13.5 30.0 6.2 111.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 0.5
	#indice steso
	echo "ctpq time 0.6 off 0 pos (-6.4 22.6 4.6 62.9 -59.9 -3.0 -2.9 12.5 43.2 13.5 30.0 6.2 7.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 1.0
	echo "set all cun" | yarp rpc /icub/face/emotions/in
	go_home	
}

domanda(){
	go_home
	sleep 1.0
	#indice steso
	echo "ctpq time 2.0 off 0 pos (-69.3 34.9 3.9 62.9 -59.9 -3.0 -2.9 40.0 40.0 13.5 37.8 6.2 7.0 58.7 145.5 237.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 3.0
	go_home
}

idea(){
	go_home
	sleep 1.0
	#indice steso
	echo "ctpq time 2.0 off 0 pos (-68.2 58.7 3.3 102.7 -50.4 21.8 -4.5 41.1 36.9 15.9 77.2 22.4 14.2 72.9 122.2 196.7)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 3.0
	go_home
}

andiamo(){

	echo "ctpq time 1.0 off 0 pos (-5.6 23.1 4.3 30.0 -23.9 -3.0 -2.9 39.3 28.8 7.7 29.6 31.9 41.9 50.2 49.9 114.1)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 2.0 off 0 pos (5.5 48.2 32.2 104.6 -1.2 -15.3 30.4 9.4 15.4 0.0 27.2 62.1 68.6 65.7 59.3 178.4)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 0.5
	echo "ctpq time 1.0 off 0 pos (5.5 48.2 32.2 104.6 10.0 -15.3 -13.0 9.4 15.4 0.0 27.2 62.1 68.6 65.7 59.3 178.4)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 0.5
	echo "ctpq time 1.0 off 0 pos (5.5 48.2 32.2 104.6 -1.2 -15.3 30.4 9.4 15.4 0.0 27.2 62.1 68.6 65.7 59.3 178.4)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 0.5
	echo "ctpq time 1.0 off 0 pos (5.5 48.2 32.2 104.6 10.0 -15.3 -13.0 9.4 15.4 0.0 27.2 62.1 68.6 65.7 59.3 178.4)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 1.5
	go_home_helperL
	go_home_helperR
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