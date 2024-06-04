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

#######################################################################################
# ICUB BASIC MOTION FUNCTIONS:                                                        #
speak() {
    #echo "\"$1\"" | yarp write ... /iSpeak
    echo "\"$1\"" | yarp write ... /acapelaSpeak/speech:i
    #write_to_screen "$1" 
}


write_to_screen() {
    echo $1 | yarp write ... /interactionInterface/text:i
}


breathers() {
    echo "$1" | yarp rpc /iCubBreatherT/rpc:i
    echo "$1" | yarp rpc /iCubBreatherH/rpc:i
    echo "$1" | yarp rpc /iCubBreatherRA/rpc:i
    sleep 0.4
    echo "$1" | yarp rpc /iCubBreatherLA/rpc:i
}

breathersT() {
    echo "$1" | yarp rpc /iCubBreatherT/rpc:i
}

breathersL() {
    echo "$1" | yarp rpc /iCubBreatherLA/rpc:i
}

breathersR() {
    echo "$1" | yarp rpc /iCubBreatherRA/rpc:i
}

breatherH() {
    echo "$1" | yarp rpc /iCubBreatherH/rpc:i
}

stop_breathers() {
    breathers "stop"
}

start_breathers() {
    breathers "start"
}

go_home_human(){

    echo "set all hap" | yarp rpc /icub/face/emotions/in
    breathers "stop"

    echo "ctpq time 2.0 off 0 pos (-1.4 15.8 16.0 15.0 -19.8 -0.32 -9.1 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-4.4 13.9 15.02 22.7 -6.7 -8.8 1.4 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc

    sleep 1.0
    echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i  
    breathers "start"

}



go_home() {
    echo "set all hap" | yarp rpc /icub/face/emotions/in
    breathers "stop"
    go_home_helper 2.0
    sleep 1.0
    echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i  
    breathers "start"
}

go_home_helper() {
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms over the table
    echo "set all hap" | yarp rpc /icub/face/emotions/in    
    go_home_helperR $1
    go_home_helperL $1
    # echo "ctpq time 1.0 off 0 pos (0.0 0.0 10.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    # go_home_helperH $1
    go_home_helperT $1
}

go_home_helperL()
{
    # echo "ctpq time $1 off 0 pos (-30.0 36.0 0.0 60.0 0.0 0.0 0.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home_helperR()
{
    # echo "ctpq time $1 off 0 pos (-30.0 36.0 0.0 60.0 0.0 0.0 0.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helperH()
{
    #echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0) 
    echo "ctpq time $1 off 0 pos (0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
}

go_home_helperT()
{
    echo "ctpq time $1 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
}


greet_with_right_thumb_up() {
    breathers "stop"
    echo "ctpq time $1 off 0 pos (-44.0 36.0 54.0 91.0 -45.0 0.0 12.0 21.0 14.0 0.0 0.0 59.0 140.0 80.0 125.0 210.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.5 && smile && sleep 1.5
    go_home_helper 1.5
    sleep 2.0
    breathers "start"
}

greet_with_left_thumb_up() {
    breathers "stop"
    echo "ctpq time 2.0 off 0 pos (-44.0 36.0 54.0 91.0 -45.0 0.0 12.0 21.0 14.0 0.0 0.0 59.0 140.0 80.0 125.0 210.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.5 && smile && sleep 1.5
    #go_home_helperL 1.5
    breathers "start"
}

warning_left_index() {
	breathers "stop"
	echo "ctpq time 2.0 off 0 pos (-52.7 28.0 45.4 91.0 -60.0 2.2 -3.3 13.3 14.2 0.0 126.0 0.0 0.0 54.0 124.0 217.5)" | yarp rpc /ctpservice/left_arm/rpc
	sleep 2.5
    	go_home
	breathers "start"    
}

greet_like_god() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -20.0 2.0 20.0 29.0 3.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -20.0 2.0 20.0 29.0 3.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.0
    echo "ctpq time 0.7 off 0 pos (-70.0 50.0 -30.0 80.0 40.0 -5.0 10.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.7 off 0 pos (-70.0 50.0 -30.0 80.0 40.0 -5.0 10.0)" | yarp rpc /ctpservice/left_arm/rpc
 
    speak "Ciao a tutti!"
    sleep 2.0
    speak "Io sono aicab"
    echo "ctpq time 0.7 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -20.0 2.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.7 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -20.0 2.0)" | yarp rpc /ctpservice/left_arm/rpc

    # echo "ctpq time 0.7 off 0 pos (-70.0 50.0 -30.0 80.0 40.0 -5.0 10.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time 0.7 off 0 pos (-70.0 50.0 -30.0 80.0 40.0 -5.0 10.0)" | yarp rpc /ctpservice/left_arm/rpc

    # echo "ctpq time 0.7 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -20.0 2.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time 0.7 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -20.0 2.0)" | yarp rpc /ctpservice/left_arm/rpc
    # sleep 1.5 && smile
    sleep 1.0 && smile

    go_home_helper 2.0
}

mostra_muscoli() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -30.0 33.0 -79.0 0.0 -4.0 49.0 7.0 0.0 39.0 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -30.0 33.0 -79.0 0.0 -4.0 49.0 7.0 0.0 39.0 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -30.0 93.0 -79.0 0.0 -4.0 49.0 17.0 0.0 39.0 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.0 off 0 pos (-27.0 78.0 -30.0 93.0 -79.0 0.0 -4.0 49.0 17.0 0.0 39.0 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/left_arm/rpc
    speak "Sono troppo forte!"    

    sleep 2.0
    smile

    go_home
    breathers "start"
}



right_up_left_down() {
    breathers "stop"
    echo "ctpq time 2 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 49.0 17.0 0.0 39.0 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (28.8571428571429 42.0989010989011 36.3993406593407 55.3626373626374 10.7111523058853 -9.71428571428572 8.4835164835165 9.25 39.4 2.72710485133021 59.4652285348142 37.7590605794557 63.0330762675756 49.3703703703704 58.7897869620792 105.658584392015)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2 off 0 pos (22.010 0 -8)" | yarp rpc /ctpservice/torso/rpc
    echo "abs 60 10 0" | yarp write ... /iKinGazeCtrl/angles:i
    sleep 3.0
    go_home_helper 2.0
    breathers "start"
}

vai_nello_spazio() {
    breathers "stop"
    echo "ctpq time 2.0 off 0 pos (-42.0 36.0 -12.0 101.0 -5.0 -5.0 -4.0 17.0 57.0 87.0 140.0 0.0 0.0 87.0 176.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 3.0
    smile
    echo "ctpq time 2.0 off 0 pos (-1.4 15.8 16.0 15.0 -19.8 -0.32 -9.1 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/right_arm/rpc
    #go_home_human 2.0
}


left_up_right_down() {
    breathers "stop"
    echo "ctpq time 2 off 0 pos (-27.0 78.0 -37.0 93.0 -79.0 0.0 -4.0 49.0 17.0 0.0 39.0 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2 off 0 pos (28.8571428571429 42.0989010989011 36.3993406593407 55.3626373626374 10.7111523058853 -9.71428571428572 8.4835164835165 9.25 39.4 2.72710485133021 59.4652285348142 37.7590605794557 63.0330762675756 49.3703703703704 58.7897869620792 105.658584392015)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-22.010 0 -8)" | yarp rpc /ctpservice/torso/rpc
    echo "abs -60 10 0" | yarp write ... /iKinGazeCtrl/angles:i    
    sleep 3.0
    go_home_helper 2.0
    breathers "start"
}

torso_right_left_up() {  #aaa
    moving_torso_right 5
    echo "ctpq time 5 off 0 pos (-6.39560439560441 63.021978021978 -64.8753846153846 24.2417582417582 6.27485247711095 -12.2637362637363 7.78021978021977 25.0 18.15 25.4188106416275 9.05941905168731 34.2472080772608 32.355615679591 51.962962962963 49.4161184490839 28.9798185117967)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 3.0
    go_home_helper 2.0
}

torso_left_right_up() {  #aaa
    moving_torso_left 5
    echo "ctpq time 5 off 0 pos (-6.39560439560441 63.021978021978 -64.8753846153846 24.2417582417582 6.27485247711095 -12.2637362637363 7.78021978021977 25.0 18.15 25.4188106416275 9.05941905168731 34.2472080772608 32.355615679591 51.962962962963 49.4161184490839 28.9798185117967)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 3.0
    go_home_helper 2.0
}


opposite_muscles() {  #aaa
    echo "set all ang" | yarp rpc /icub/face/emotions/in
    echo "ctpq time 3 off 0 pos (0.1758241758242 65.0549450549451 44.750989010989 75.2637362637363 -50.07675435493229 -4.61538461538461 19.2967032967033 26.25 29.85 6.63946791862284 34.2623237932507 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 3 off 0 pos (0.1758241758242 65.0549450549451 44.750989010989 75.2637362637363 -50.07675435493229 -4.61538461538461 19.2967032967033 26.25 29.85 6.63946791862284 34.2623237932507 49.0 87.0 67.0 130.0 200.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (0 0 19)" | yarp rpc /ctpservice/torso/rpc
    sleep 1.0
    echo "abs 0 20 0" | yarp write ... /iKinGazeCtrl/angles:i
    speak "voglio essere come ulk!"
    sleep 3.0
    go_home_helper 2.0
}


dabbing_right() {  #aaa
    echo "ctpq time 2 off 0 pos (14.8791208791209 91.3296703296703 -0.875384615384615 114.527472527473 -5.90339196513224 -6.54945054945054 -3.12087912087912 7.0 23.05 3.11834115805947 69.7172575822298 31.1743371378402 120.127239028547 46.7777777777778 146.987486152535 191.411760435572)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2 off 0 pos (52.2527472527472 102.956043956044 -21.7839560439561 15.1868131868132 3.7772227489493 -18.8571428571429 23.7802197802198 10.9974404857323 15.9158417569927 31.9651821688813 13.3979746835443 31.9358683525474 42.7038461538462 47.5233981281498 45.2020234722784 80.9195402298851)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "abs -28 -20 0" | yarp write ... /iKinGazeCtrl/angles:i    
    sleep 2.0
    go_home_human 2.0
}

dabbing_left() {  #aaa
    echo "ctpq time 2 off 0 pos (14.8791208791209 91.3296703296703 -0.875384615384615 114.527472527473 -5.90339196513224 -6.54945054945054 -3.12087912087912 7.0 23.05 3.11834115805947 69.7172575822298 31.1743371378402 120.127239028547 46.7777777777778 146.987486152535 191.411760435572)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (52.2527472527472 102.956043956044 -21.7839560439561 15.1868131868132 3.7772227489493 -18.8571428571429 23.7802197802198 10.9974404857323 15.9158417569927 31.9651821688813 13.3979746835443 31.9358683525474 42.7038461538462 47.5233981281498 45.2020234722784 80.9195402298851)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5
    echo "abs 28 -20 0" | yarp write ... /iKinGazeCtrl/angles:i    
    sleep 2.0
    go_home_human 2.0
}

pushed_reaction(){
	
    echo "set all sad" | yarp rpc /icub/face/emotions/in

    echo "ctpq time 1.5 off 0 pos (-6.21978021978023 75.1538461538462 -48.3479120879121 63.8021978021978 -24.6547186098179 -14.989010989011 5.31868131868131 39.5 29.4 5.07452269170579 27.854805638616 31.6133187006146 36.1902982530891 50.8518518518519 51.1204218150831 86.6023230490018)" | yarp rpc /ctpservice/right_arm/rpc

    echo "ctpq time 1.5 off 0 pos (-6.21978021978023 75.1538461538462 -48.3479120879121 63.8021978021978 -24.6547186098179 -14.989010989011 5.31868131868131 39.5 29.4 5.07452269170579 27.854805638616 31.6133187006146 36.1902982530891 50.8518518518519 51.1204218150831 86.6023230490018)" | yarp rpc /ctpservice/left_arm/rpc

    echo "ctpq time 1.5 off 0 pos (0.0 0.0 -21.1)" | yarp rpc /ctpservice/torso/rpc

}

smile() {
    echo "set all hap" | yarp rpc /icub/face/emotions/in
}

surprised() {
    echo "set mou sur" | yarp rpc /icub/face/emotions/in
    echo "set leb sur" | yarp rpc /icub/face/emotions/in
    echo "set reb sur" | yarp rpc /icub/face/emotions/in
}

neutral() {
    echo "set mou neu" | yarp rpc /icub/face/emotions/in
    echo "set leb neu" | yarp rpc /icub/face/emotions/in
    echo "set reb neu" | yarp rpc /icub/face/emotions/in
}

sad() {
    echo "set mou sad" | yarp rpc /icub/face/emotions/in
    echo "set leb sad" | yarp rpc /icub/face/emotions/in
    echo "set reb sad" | yarp rpc /icub/face/emotions/in
}

cun() {
    echo "set mou neu" | yarp rpc /icub/face/emotions/in
    echo "set reb cun" | yarp rpc /icub/face/emotions/in
    echo "set leb cun" | yarp rpc /icub/face/emotions/in
}

angry() {
    echo "set all ang" | yarp rpc /icub/face/emotions/in
}

saluta() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 12.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 1.0 && speak "Ciao amici! Benvenuti!"
    #sleep 2.0 && speak "Hello, my name is aikub, nice to meet you"
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 12.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5    
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 12.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    smile
    sleep 1.0
    go_home_human
    smile

}



start_sound_localiser(){
    echo "sus" | yarp rpc /DeepFaceTracker
    close_eyes
    sleep 1.0
    echo "start" | yarp rpc /SoundLocaliser


}

start_face_tracker(){
    echo "stop" | yarp rpc /SoundLocaliser
    open_eyes
    sleep 1.0

    echo "run" | yarp rpc /DeepFaceTracker
}




close_eyes(){
    echo "set pos 0 60" | yarp rpc /icub/face/rpc:i
}

open_eyes(){
    echo "set pos 0 1.0" | yarp rpc /icub/face/rpc:i
}

ciao_gesto() {
    breathers "stop"
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0 
    #sleep 2.0 && speak "Hello, my name is aikub, nice to meet you"
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5    
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    smile
    sleep 1.0
    go_home
    smile

}

look_left(){
    echo "abs -40 20 0" | yarp write ... /iKinGazeCtrl/angles:i    
}

look_right(){
    echo "abs 40 20 0" | yarp write ... /iKinGazeCtrl/angles:i    
}




saluta_bye() {
    breathers "stop"
    echo "ctpq time 2.0 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 2.0 && speak "Ciao, a presto!"
    #sleep 2.0 && speak "Thank you for visiting me, goodbye !"
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 0.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    smile
    sleep 1.0
    go_home
    smile
}

fonzie() {
    breathers "stop"
    echo "ctpq time 2 off 0 pos (0 0 -20)" | yarp rpc /ctpservice/torso/rpc
    #echo "ctpq time 1.5 off 0 pos ( -3.0 57.0   3.0 106.0 -9.0 -8.0 -10.0 22.0 10.0 10.0 0.0 62.0 146.0 90.0 130.0 250.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.5 off 0 pos ( -3.0 57.0   3.0 106.0 -9.0 -8.0 -10.0 22.0 10.0 10.0 0.0 62.0 146.0 90.0 130.0 250.0)" | yarp rpc /ctpservice/left_arm/rpc
    speak ""
    sleep 1.5
    smile
    go_home_human
    breathers "start"
}

do_cat() {
	speak "#CAT#"
}


do_cow() {
	speak "#COW#"
}


do_lion() {

	angry
	#echo "ctpq time 1.5 off 0 pos (12.9  97.14 -51.6 96.2 -27.2 0.48  42.85 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
	#echo "ctpq time 1.5 off 0 pos (12.9  97.14 -51.6 96.2 -27.2 0.48  42.85 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
	#echo "ctpq time 1.5 off 0 pos (0.0 0.0 20)" | yarp rpc /ctpservice/torso/rpc
	speak "#LION#"
	sleep 1.5
	go_home
}

pref_col(){
	speak "qualee' il tuo colore preferito?"
}

do_pig() {
	speak "#PIG#"
}

do_horse() {
	speak "#HORSE#"
}

do_wolf() {
	speak "#WOLF#"
}


led_green(){
	smile	
	echo "set col green" | yarp rpc /icub/face/emotions/in
}

led_red(){
	smile
	 echo "set col red" | yarp rpc /icub/face/emotions/in
}

led_pink(){
	smile
	 echo "set col magenta" | yarp rpc /icub/face/emotions/in
}

led_yellow(){
	smile
	 echo "set col yellow" | yarp rpc /icub/face/emotions/in
}

led_cyan(){
	smile
	echo "set col cyan" | yarp rpc /icub/face/emotions/in
}


led_blue(){
	smile
	echo "set col blue" | yarp rpc /icub/face/emotions/in
}

led_purple(){
	smile
	echo "set col purple" | yarp rpc /icub/face/emotions/in
}

led_white(){
	smile
	echo "set col white" | yarp rpc /icub/face/emotions/in
}


violin_move_right(){
	echo "ctpq time 1.5 off 0 pos (7.9 54.1 44.3 100.5 6.8 -0.06 13.6 11.2 28.9 8.3 32.2 34.5 54.3 49.3 49.08 120.9)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 1.5 off 0 pos (-10.1  26.2 49.6 100.5 3.66 8.6 17.3 9.76 29.65 7.05 32.9 34.9 54.0 48.0 51.9 140.4)" | yarp rpc /ctpservice/right_arm/rpc
}

play_violin(){
	
	echo "abs -5 -15 0" | yarp write ... /iKinGazeCtrl/angles:i
	echo "ctpq time 1.5 off 0 pos (-7.1 35.6 -2.3 106.04 -38.98 5.8 12.5 26.17 29.38 6.54 30.0 33.05 38.3 48.79 50.37 57.9)" | yarp rpc /ctpservice/left_arm/rpc		
	echo "ctpq time 1.5 off 0 pos (-10.1  26.2 49.6 100.5 3.66 8.6 17.3 9.76 29.65 7.05 32.9 34.9 54.0 48.0 51.9 140.4)" | yarp rpc /ctpservice/right_arm/rpc
	
	aplay /usr/local/src/robot/iCubContrib/share/ICUBcontrib/contexts/icub-interaction-demos/bach.wav &

	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right
	violin_move_right


	sleep 35
	go_home

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


pointing_to_right_forearm() {
	echo "ctpq time $1 off 0 pos (-17.989011 60.142857 48.281978 118.043956 24.212504 -16.285714 -1.978022 13.510583 58.4198 22.535264 51.734322 0.0 1.165385 57.962563 153.660138 155.057471)" | yarp rpc /ctpservice/left_arm/rpc

	echo "ctpq time $1 off 0 pos (-56.769231 23.901099 52.663077 44.989011 -50.079599 -20.967033 -4.175824 11.0 58.411 0.0 47.0 1.8 1.7 4.5 1.7 0.0)" | yarp rpc /ctpservice/right_arm/rpc


   }


   pointing_to_eyes_right() {
	#echo "ctpq time $1 off 0 pos (-19.659341 52.582418 3.886374 120.945055 -18.930689 16.923077 -7.692308 12.882311 36.17322 -0.182267 1.10141 1.069375 0.780769 74.521238 115.618859 197.011494)" | 	 yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time $1 off 0 pos (-41.8 64.4 14.5 103.7 -37.2 21.0 -12.9 12.5 36.5 0.0 3.5 1.8 0.0 74.9 63.0 189.0)" | 	 yarp rpc /ctpservice/right_arm/rpc


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

   open_both_arms() {
	breathers "stop"
	echo "ctpq time 2.0 off 0 pos (-5.868132 45.791209 -18.721538 25.571429 -59.58446 -7.252747 2.953846 30.25 28.9 12.899249 33.407988 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 2.0 off 0 pos (-5.868132 45.791209 -18.721538 25.571429 -59.58446 -7.252747 2.953846 30.25 28.9 12.899249 33.407988 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
        sleep 3.0
	breathers "start"
	
	go_home_human

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

   left_arm_down() {
	echo "ctpq time 2 off 0 pos (0.0219 26.802 0.003 15.010 0.000 -0.043 0.043 15.0 45.0 -1.185 10.768 0.006 0.399 1.222 3.826 -1.419)" | yarp rpc /ctpservice/left_arm/rpc

   }

   right_arm_down() {
	echo "ctpq time 2 off 0 pos (0.032 29.989 -0.069 15.010 0.000 0.043 -0.043 15.395 45.023 -1.039 0.37 0.325 0.780 0.367 0.280 -1.839)" | yarp rpc /ctpservice/right_arm/rpc



   }

   look_nose() {
	echo "ctpq time $1 off 0 pos (0 0 0 -24.018 0 26.5 )" | yarp rpc /ctpservice/head/rpc
   }
   
   look_nose_iKinRel() {
       echo "rel 0 -20 50" | yarp write ... /iKinGazeCtrl/angles:i
   }
   
   make_paper() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 15.0 0.0 10.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
   }

   make_rock() {
	echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 50.25 18.95 8.986886 30.417813 52.0523 51.303208 60.592593 66.859663 180.667659)" | yarp rpc /ctpservice/left_arm/rpc

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

   lift_arm_left_infront() {
	echo "ctpq time $1 off 0 pos ( -67.4945054945055 22.9340659340659 -12.8314285714286 23.4505494505495 5.77391144381394 2.68131868131869 -3.20879120879121 29.75 32.05 7.81317683881065 34.6894916702264 32.9302633889377 34.4859948870899 49.0 47.285739241585 19.9054083484574)" | yarp rpc /ctpservice/left_arm/rpc

   }

   lift_arm_right_infront() {
	echo "ctpq time $1 off 0 pos ( -67.3076923076923 29.1098901098901 -15.8938461538462 23.978021978022 16.8880099622172 3.91208791208791 7.60439560439559 38.0132034977177 33.290907725409 0.246365195027863 30.7578300180832 31.1920974339903 41.55 49.6832253419726 53.2959125859976 103.333333333333)" | yarp rpc /ctpservice/right_arm/rpc

   }

   pointing_up_arm_right_and_elbow() {
	echo "ctpq time $1 off 0 pos (-35.3186813186813 19.3296703296703 50.3773626373626 96.5934065934066 -44.388116093792 9.36263736263737 19.7362637362637 32.0 27.2 11.7255399061033 24.8646304997864 32.9302633889377 38.7467533020878 49.3703703703704 53.6768768640818 97.4916152450091)" | yarp rpc /ctpservice/left_arm/rpc

	echo "ctpq time $1 off 0 pos (-75.9230769230769 35.4395604395604 12.5017582417582 95.8021978021978 -4.79962358668119 -5.23076923076923 -4.0 13.1964469724028 77.9058551536557 -0.182267466780957 83.1990596745027 1.8131461509855 0.780769230769238 57.6025917926566 152.446054229057 218.275862068966)" | yarp rpc /ctpservice/right_arm/rpc
   }

   pointing_up_arm_left() {
	#echo "ctpq time $1 off 0 pos (-35.3186813186813 19.3296703296703 50.3773626373626 96.5934065934066 -44.388116093792 9.36263736263737 19.7362637362637 32.0 27.2 11.7255399061033 24.8646304997864 32.9302633889377 38.7467533020878 49.3703703703704 53.6768768640818 97.4916152450091)" | yarp rpc /ctpservice/right_arm/rpc

	echo "ctpq time $1 off 0 pos (-75.9230769230769 35.4395604395604 12.5017582417582 95.8021978021978 -4.79962358668119 -5.23076923076923 -4.0 13.1964469724028 77.9058551536557 0.182267466780957 83.1990596745027 1.8131461509855 0.780769230769238 57.6025917926566 152.446054229057 218.275862068966)" | yarp rpc /ctpservice/left_arm/rpc
   }


   rotating_torso_right() {
	echo "ctpq time $1 off 0 pos (33 0 0)" | yarp rpc /ctpservice/torso/rpc
   }

   rotating_torso_left() {
	echo "ctpq time $1 off 0 pos (-33 0 0)" | yarp rpc /ctpservice/torso/rpc
   }

   putting_torso_forward() {
	echo "ctpq time $1 off 0 pos (0 0 25)" | yarp rpc /ctpservice/torso/rpc

   }




    grazie_arrivederci_signlanguage(){
        grazie_signlanguage
        arrivederci_signlanguage
    }

    grazie_signlanguage(){
	go_home
	breathers "stop"
	echo "ctpq time 1.5 off 0 pos (-31.3516483516484 25.6813186813187 23.6665934065934 102.21978021978 -59.6031386644403 33.3626373626374 2.594065934066 0.316812101641972 22.451789469411 39.6805700814402 23.8862206148282 0.325604313871338 5.01153846153849 0.00719942404607821 2.70910562525293 -0.114942528735639)" | yarp rpc /ctpservice/right_arm/rpc
	sleep 1.0
	echo "ctpq time 1.5 off 0 pos (-22.9120879120879 29.9010989010989 27.3589010989011 58.7032967032967 -69.0431884755261 -7.60439560439559 10.6813186813187 20.7356604829912 12.7493577720943 57.2545092156022 4.71804701627488 0.697489773149869 3.47307692307695 0.367170626349889 1.49502225819506 -2.41379310344826)" | yarp rpc /ctpservice/right_arm/rpc
   	sleep 1.0 
	go_home
	breathers "start"
    }

    arrivederci_signlanguage(){
	go_home
	breathers "stop"

	echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 33.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 1.5 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/left_arm/rpc

	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 40.2121004775089 20.0 0.0 11.0 10.366511714392 116.55 23.7652987760979 115.214164305949 178.620689655172)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 40.2121004775089 20.0 0.0 11.0 10.366511714392 116.55 23.7652987760979 115.214164305949 178.620689655172)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 40.2121004775089 20.0 0.0 11.0 10.366511714392 116.55 23.7652987760979 115.214164305949 178.620689655172)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 40.2121004775089 20.0 0.0 11.0 10.366511714392 116.55 23.7652987760979 115.214164305949 178.620689655172)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.02 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 16.9660269356652 20.0 0.0 11.0 -0.0462811454072067 0.0115384615384926 0.00719942404607821 1.89971671388102 1.60919540229884)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 40.2121004775089 20.0 0.0 11.0 10.366511714392 116.55 23.7652987760979 115.214164305949 178.620689655172)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 0.7 off 0 pos (-27.0 78.0 -37.0 93.0 7.0 0.0 -4.0 40.2121004775089 20.0 0.0 11.0 10.366511714392 116.55 23.7652987760979 115.214164305949 178.620689655172)" | yarp rpc /ctpservice/left_arm/rpc

   	sleep 1.0 
	go_home
	breathers "start"
    }



#######################################################################################
# FUNCTIONS EXPLAINING ICUB PARTS                                                     #
#######################################################################################
explain_eyes() {
	 breathers "stop"
    	 pointing_to_eyes_right 2.0
	 speak "Questi sono i miei occhi, con i quali posso vedere il mondo"
         sleep 3.0 

	 go_home
    }

explain_skin_forearm() {
	breathers "stop"
	pointing_to_left_forearm 2.0
	speak "Con la mia pelle artificiale posso sentire quando mi toccate" 
	sleep 3.0 
	go_home
}

explain_nose(){
	speak "Guardate! posso guardarmi la punta del naso." 
	look_nose_iKinRel 
	sleep 3.0 
	go_home_helperH

}

#######################################################################################
# FUNCTIONS EXPLAINING ICUB EMOTIONS:                                                     #
#######################################################################################
present_emotions() {
	 speak "posso essere arrabbiato " 
	 sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 echo "set all ang" | yarp rpc /icub/face/emotions/in
	speak "#AARGH02#"
	sleep 2.0 
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 speak "felice "
	sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 echo "set all hap" | yarp rpc /icub/face/emotions/in
	speak "#LAUGH01#" 
	 sleep 2.0
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 speak "triste " 
	sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	 echo "set all sad" | yarp rpc /icub/face/emotions/in
	speak "#CRY03#"
	 sleep 2.0
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	echo "set all hap" | yarp rpc /icub/face/emotions/in
	 
    }

