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


mostra_muscoli() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 -79.0 0.0 -4.0 26.0 27.0 0.0 29.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 -79.0 0.0 -4.0 26.0 27.0 0.0 29.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 26.0 67.0 0.0 99.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 26.0 67.0 0.0 99.0 59.0 117.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    speak "of superheroes"
    sleep 3.0
    smile
    go_home_helper 2.0
    breathers "start"
}


smile() {
    echo "set all hap" | yarp rpc /icub/face/emotions/in
}

surprised() {
    echo "set mou sur" | yarp rpc /icub/face/emotions/in
    echo "set leb sur" | yarp rpc /icub/face/emotions/in
    echo "set reb sur" | yarp rpc /icub/face/emotions/in
}

sad() {
    echo "set mou sad" | yarp rpc /icub/face/emotions/in
    echo "set leb sad" | yarp rpc /icub/face/emotions/in
    echo "set reb sad" | yarp rpc /icub/face/emotions/in
}

ciao() {
    speak "Hello! My name is icub."
}

vai_nello_spazio() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-42.0 36.0 -12.0 101.0 -5.0 -5.0 -4.0 17.0 57.0 87.0 140.0 0.0 0.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 2.0
    smile
    go_home
}

meteo_bot() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-55.0 49.0 -4.0 77.0 73.0   0.0 15.0 21.0 40.0 30.0 91.0 5.0 35.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (0.0 0.0 30.0 0.0 -10.0 10.0)" | yarp rpc /ctpservice/head/rpc
    sleep 2.0
    echo "ctpq time 0.8 off 0 pos (-70.0 47.0 -3.0 55.0 81.0 -11.0  5.0 21.0 40.0 30.0 91.0 5.0 35.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (0.0 0.0 30.0 0.0 -10.0 5.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 0.8 off 0 pos (-55.0 49.0 -4.0 77.0 73.0   0.0 15.0 21.0 40.0 30.0 91.0 5.0 35.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.0 && blink
    smile
    echo "ctpq time 1.0 off 0 pos (0.0 0.0 0.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    blink
    go_home
}

saluta() {
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    # sleep 2.0 && speak "Ciao Ciao, spero che verrete presto a trovarmi!"
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    
    go_home
    
}


closing_remarks() {
    meteo_bot
    speak "That is all from icub. File $1 ended."
    sleep 1.5 && blink
    sleep 3.0 && blink && smile
    speak "Good luck, makers."
    smile
    greet_with_right_thumb_up   
    smile
}

no_testa() {
    head "stop"
    echo "ctpq time 0.5 off 0 pos (0.0 0.0  15.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 0.5 off 0 pos (0.0 0.0  -5.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 0.5 off 0 pos (0.0 0.0  15.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 0.5 off 0 pos (0.0 0.0  -5.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 0.5 off 0 pos (0.0 0.0   5.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    head "start"
    go_home
}

fonzie() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos ( -3.0 57.0   3.0 106.0 -9.0 -8.0 -10.0 22.0 10.0 10.0 20.0 62.0 146.0 90.0 130.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos ( -3.0 57.0   3.0 106.0 -9.0 -8.0 -10.0 22.0 10.0 10.0 20.0 62.0 146.0 90.0 130.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.5
    smile
    go_home
    breathers "start"
}

attacco_grafica() {
    head "stop"
    echo "ctpq time 1.0 off 0 pos (0.0 0.0 30.0 0.0 -10.0 5.0)" | yarp rpc /ctpservice/head/rpc
    speak "$1"
    sleep 2.0
    go_homeH
}

cun() {
    echo "set reb cun" | yarp rpc /icub/face/emotions/in
    echo "set leb cun" | yarp rpc /icub/face/emotions/in
}

angry() {
    echo "set all ang" | yarp rpc /icub/face/emotions/in
}



#######################################################################################
# "ATTENTION_MODULE" FUNCTION:                                                        #
#######################################################################################
   attention_suspend() {
	yarp disconnect /icub/camcalib/left/out /logPolarTransform/icub/left_cam/image:i
	attentionPrioritiser_suspend
	selectiveAttention_suspend

   }

   attention_resume() {
	yarp connect /icub/camcalib/left/out /logPolarTransform/icub/left_cam/image:i
	attentionPrioritiser_resume
        selectiveAttention_resume
   }  


   attentionPrioritiser_suspend() {
	 echo "sus" | yarp rpc /attPrioritiser/icub
   }

   attentionPrioritiser_resume() {
	 echo "res" | yarp rpc /attPrioritiser/icub
   }

   selectiveAttention_suspend() {
	 echo "sus" | yarp rpc /selectiveAttentionEngine/icub/left_cam
   }

   selectiveAttention_resume() {
	 echo "res" | yarp rpc /selectiveAttentionEngine/icub/left_cam
   }

   faceDetector_suspend() {
	 echo "sus" | yarp rpc /faceDetector/control/rpc
   }

   faceDetector_resume() {
	 echo "res" | yarp rpc /faceDetector/control/rpc
   }

#######################################################################################
# FUNCTIONS POINTING:                                                                 #
#######################################################################################
   pointing_to_left_forearm() {
	echo "ctpq time $1 off 0 pos (-56.769231 23.901099 52.663077 44.989011 -50.079599 -20.967033 -4.175824 11.0 45.05 0.379687 3.933405 -0.432335 -0.8783 0.111111 1.269548 -8.225263)" | yarp rpc /ctpservice/left_arm/rpc

	echo "ctpq time $1 off 0 pos (-17.989011 60.142857 48.281978 118.043956 24.212504 6.285714 -1.978022 13.510583 58.4198 22.535264 51.734322 -0.790052 1.165385 57.962563 153.660138 155.057471)" | yarp rpc /ctpservice/right_arm/rpc

   }



   pointing_to_eyes_right() {
	echo "ctpq time $1 off 0 pos (-19.659341 52.582418 3.886374 120.945055 -18.930689 16.923077 -7.692308 12.882311 36.17322 -0.182267 1.10141 1.069375 0.780769 74.521238 115.618859 197.011494)" | 	 yarp rpc /ctpservice/right_arm/rpc

   }


   moving_torso_right() {
	echo "ctpq time $1 off 0 pos (1.923077 -20.604396 -15.009011)" | yarp rpc /ctpservice/torso/rpc

   }

   moving_torso_left() {
	echo "ctpq time $1 off 0 pos (0.340659 20.296703 -15.054945)" | yarp rpc /ctpservice/torso/rpc

   }

   moving_torso_back() {
	echo "ctpq time $1 off 0 pos (0.0 0.0 -15.054945)" | yarp rpc /ctpservice/torso/rpc

   }

   open_arm_left() {
	echo "ctpq time $1 off 0 pos (-5.868132 45.791209 -18.721538 62.571429 -19.58446 -7.252747 42.153846 30.25 28.9 12.899249 33.407988 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	
   }

   open_arm_right() {
	echo "ctpq time $1 off 0 pos (-5.868132 45.791209 -18.721538 62.571429 -19.58446 -7.252747 42.153846 30.25 28.9 12.899249 33.407988 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
	
   }

   drop_arm_right() {
	echo "ctpq time $1 off 0 pos (-6.032967 23.043956 3.974286 15.010989 -23.999533 -3.032967 -3.032967 39.583884 28.987737 9.247651 30.396166 32.679639 41.934615 50.043197 49.653662 99.885057)" | yarp rpc /ctpservice/right_arm/rpc
	
   }

   lift_arm_left() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 93.0 -24.0 -3.0 -3.0 50.25 18.95 8.986886 30.417813 52.0523 51.303208 60.592593 66.859663 140.667659)" | yarp rpc /ctpservice/left_arm/rpc

   }

   drop_arm_left() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 53.0 -24.0 -3.0 -3.0 50.25 18.95 8.986886 30.417813 52.0523 51.303208 60.592593 66.859663 140.667659)" | yarp rpc /ctpservice/left_arm/rpc

   }

   look_nose() {
	echo "ctpq time $1 off 0 pos (0 0 0 -24.018 0 26.5 )" | yarp rpc /ctpservice/head/rpc
   }

   make_paper() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 15.0 0.0 10.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
   }

   make_rock() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 50.25 18.95 8.986886 30.417813 52.0523 51.303208 60.592593 66.859663 140.667659)" | yarp rpc /ctpservice/left_arm/rpc

   }

   make_scissors() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 50.25 18.95 8.986886 30.417813 0.0 0.0 0.0 0.0 140.667659)" | yarp rpc /ctpservice/left_arm/rpc

   }

   get_random_num() {
	RANGE=$1
	randNum=$RANDOM
	let "randNum %= $RANGE"
	echo $randNum
   }

#######################################################################################
# FUNCTIONS EXPLAINING ICUB BODY:                                                     #
#######################################################################################
    explain_skin_forearm() {
    	 pointing_to_left_forearm 2.0
	 speak "With my artificial skin, I can feel when you touch me!" 
	 sleep 3.0 
	 go_home
    }

    play_shifumi() {
	drop_arm_right 2.0
	sleep 1.0	
	make_rock 2.0
	#speak "Paper!"
	lift_arm_left 1.5
	drop_arm_left 1.0
	#speak "Rock!"
	lift_arm_left 1.5
	drop_arm_left 1.0
	#speak "Scissors!"
	lift_arm_left 1.5
	drop_arm_left 1.0
	get_random_num 3   
	if [ $randNum -eq 0 ]
	then	
		make_rock 1.0
	elif [ $randNum -eq 1 ]
	then
		make_paper 1.0
	else
		make_scissors 1.0
	fi
	sleep 2.0
	#go_home
   }

   present_body() {
    	 moving_torso_back 3.0 
	 open_arm_left 2.0
	 open_arm_right 2.0
	 speak "You can touch my skin. if you want." 
	 sleep 7.0 
	 go_home
    }

   present_emotions() {
	 speak "I can be angry! " 
	 sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 echo "set all ang" | yarp rpc /icub/face/emotions/in
	sleep 1.0
	speak "#AARGH02#"
	sleep 2.0 
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 speak "Happy! "
	sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 echo "set all hap" | yarp rpc /icub/face/emotions/in
	sleep 1.0
	speak "#LAUGH03#" 
	 sleep 2.0
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 speak "Sad! " 
	sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 echo "set all sad" | yarp rpc /icub/face/emotions/in
	sleep 1.0
	speak "#CRY03#" 
	 sleep 2.0
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	echo "set all hap" | yarp rpc /icub/face/emotions/in
	 
    }

   present_nose() {
	speak "Look! I can look at the top of my nose!"
	look_nose 2.0
	sleep 3.0
	go_home
   }

#######################################################################################
# FUNCTIONS EXPLAINING ICUB EYES:                                                     #
#######################################################################################
    explain_eyes() {
    	 pointing_to_eyes_right 2.0
	 speak "These are my eyes, two cameras, with which I can see the world"
         sleep 3.0 
	 go_home
    }

#######################################################################################
# FUNCTIONS EXPLAINING ICUB BALANCING:                                                #
#######################################################################################
    explain_balancing() {
	 pointing_to_eyes_right 2.0
	 speak "I also have a sensor, in my head, this allows me, to keep my balance. Look at me, I can do gymnastics"
	 sleep 2.0
	 go_home 
    	 moving_torso_right 3.0
	 moving_torso_left 3.0
	 moving_torso_right 3.0
	 moving_torso_left 3.0
	 go_home
    }

    explain_compliance() {
	 pointing_to_left_forearm 2.0
	 speak "I have a sensor, on my arms, this allows me, to move in smooth way, during physical interaction with humans. "
	 sleep 3.0
	 go_home 
    }
   

#######################################################################################
# "MAIN" STATE MACHINE:                                                               #
#######################################################################################



   guarda_c(){
	echo "abs 8 -5 0" | yarp write ... /iKinGazeCtrl/angles:i 

   }

   guarda_g(){
	echo "abs -40 -5 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0) 

   }

   saluta_u(){
	
	guarda_c
	speak "Hello guys! Nice to meet you!"
	saluta
    }

    saluta_classic() {
	speak "Hi! I am icub."exe
	saluta
    }

   addio(){	
	guarda_c
	speak "Hello everyone from Genoa! See you soon!"
	saluta
    }

   intro(){
	guarda_c
	speak "My name is i cub. I am a humanoid robot, born at the italian, institute of technology."
	sleep 10.0
	guarda_c
	sleep 1.0
	speak "I, I, T, researchers have equipped me, with tools to interact, with human beings."
	sleep 6.0
	
	explain_eyes
	sleep 4.0
	#present_nose
	#sleep 4.0
	explain_skin_forearm
	sleep 4.0
	present_body
	sleep 5.0
	explain_compliance
	sleep 4.0
	explain_balancing
	sleep 12.0
	present_emotions
	sleep 2.0
	#saluta
	#sleep 2.0
	speak "Now, my friends will show you, other things that I can do! #LAUGH03#"
    }


    sequential_control1() {
	go_home
	sleep 2.0
	#explain_compliance
	sleep 1.0
	#explain_balancing
	sleep 1.0
	explain_eyes
	sleep 10.0
	interaction_reset
    }
    
    group_interaction() {
	attention_suspend
	faceDetector_resume
    }

    single_interaction() {
	attention_suspend
    }

    
    #Sequence 3 : S3
    group_demonstration() {
	attention_suspend
	faceDetector_resume
	sequential_control1
    }

    interaction_reset() {
	faceDetector_suspend
	sleep 2.0
	attention_restart
	go_home
    }

    attention_restart() {
	attention_resume	
    }

    complete_presentation() {
	saluta_classic
	speak "Now I'll tell you what I can do."
	intro
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

