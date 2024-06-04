#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2020 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Vannucci Fabio, Vignolo Alessia
# email:  fabio.vannucci@iit.it
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
# FUNCTIONS ANIMALZZZZ                                                                #
#######################################################################################

    coccodrilli(){
	echo "ctpq time $1 off 0 pos (-33.7 41.7 -15.7 59.7 -10.8 -8.4 10.8 20.0 29.0 3.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-33.7 41.7 -15.7 59.7 -10.8 -8.4 10.8 20.0 29.0 3.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
	
	echo "ctpq time $1 off 0 pos (-48.6 19.4 3.1 35 -4.8 -1 -2.2 20.0 29.0 3.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-48.6 19.4 3.1 35 -4.8 -1 -2.2 20.0 29.0 3.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    }

    orangotango(){
	#echo "ctpq time $1 off 0 pos (9.5 74.5 3.1 82.3 -6 -19.9 15.7 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/left_arm/rpc
	#echo "ctpq time $1 off 0 pos (9.5 74.5 3.1 82.3 -6 -19.9 15.7 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/right_arm/rpc
	
	echo "ctpq time $1 off 0 pos (-24 35.7 12.6 108 -6 -3 8 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (9.5 74.5 3.1 82.3 -6 -19.9 15.7 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/right_arm/rpc

	echo "ctpq time $1 off 0 pos (9.5 74.5 3.1 82.3 -6 -19.9 15.7 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-24 35.7 12.6 108 -6 -3 8 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/right_arm/rpc
    }


    serpenti(){
	echo "ctpq time $1 off 0 pos (-24 35.7 12.6 108 -6 -3 8 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-24 35.7 12.6 108 -6 -3 8 2.4 20 28.8 17 1.8 86.7 0.0 86.7 100.0)" | yarp rpc /ctpservice/right_arm/rpc
	
	echo "ctpq time $1 off 0 pos (-56 26.8 5.2 28.8 60 -7 10 3.6 16.8 33.3 10 0 20.4 0 30 5)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-56 26.8 5.2 28.8 60 -7 10 3.6 16.8 33.3 10 0 20.4 0 30 5)" | yarp rpc /ctpservice/right_arm/rpc


    }

   aquila(){
	echo "ctpq time $1 off 0 pos (0 55 31.5 27.8 4.8 -48 20.7 3.6 16.8 33.3 10 0 20.4 0 30 5)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (0 55 31.5 27.8 4.8 -48 20.7 3.6 16.8 33.3 10 0 20.4 0 30 5)" | yarp rpc /ctpservice/right_arm/rpc
	
	echo "ctpq time $1 off 0 pos (8.4 90.8 5 28.8 3.6 -42 10 3.6 16.8 33.3 10 0 20.4 0 30 5)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (8.4 90.8 5 28.8 3.6 -42 10 3.6 16.8 33.3 10 0 20.4 0 30 5)" | yarp rpc /ctpservice/right_arm/rpc
    }

    gatto(){
	echo "ctpq time $1 off 0 pos (-48.5 29 8.4 90.7 60 -35.7 20.8 0 15.2 42.3 10.2 0 15.3 0 30 185)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-48.5 29 8.4 90.7 60 -35.7 20.8 0 15.2 42.3 10.2 0 15.3 0 30 185)" | yarp rpc /ctpservice/right_arm/rpc
    }

    topo(){
	echo "ctpq time $1 off 0 pos (9.5 83.4 13.6 96.7 60 -79.8 12.1 0 15.2 42.3 10.2 0 15.3 0 30 185)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (9.5 83.4 13.6 96.7 60 -79.8 12.1 0 15.2 42.3 10.2 0 15.3 0 30 185)" | yarp rpc /ctpservice/right_arm/rpc
    }

    elefante() {
	echo "ctpq time $1 off 0 pos (-56.7 23.9 52.6 18.5 22.8 -20.9 -4.1 11.0 45.05 0.379687 3.933405 -0.432335 -0.8783 0.111111 1.269548 -8.225263)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-17.9 60.14 48.28 118.0 24.21 6.28 -1.97 13.5 58.4 22.5 51.734322 -0.790052 1.165385 57.962563 153.660138 155.057471)" | yarp rpc /ctpservice/right_arm/rpc

    }

    leocorni() {
	echo "ctpq time $1 off 0 pos (-48.5 29 8.4 90.7 60 -35.7 20.8 0 15.2 42.3 10.2 0 15.3 0 30 185)" | yarp rpc /ctpservice/right_arm/rpc

    }

    filastrocca_motion(){
	

	coccodrilli 1.0
	orangotango 1.0
	serpenti 1.0
	aquila 1.0
	gatto 1.0
	topo 1.0
	elefante 1.0
	leocorni 1.5


    }

    filastrocca_audio(){

	#aplay /usr/local/src/robot/cognitiveInteraction/icub-interaction-demos/app/icubDemos/conf/due_coccodrilli.wav
	mpg123 /usr/local/src/robot/iCubContrib/share/ICUBcontrib/contexts/icub-interaction-demos/coccodrilli_cropped.mp3

	}

    run_coccodrilli(){
	speak "balla con me."
	filastrocca_audio & sleep 3.0 
	filastrocca_motion &
	sleep 20.0
	go_home
	}



