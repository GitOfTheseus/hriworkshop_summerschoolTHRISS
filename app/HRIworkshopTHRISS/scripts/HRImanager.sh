#######################################################################################
# Copyright: (C) 2021 Robotics Brain and Cognitive Sciences
# Author:  Giulia Belgiovine Gonzalez Jonas
# email:  giulia.belgiovine@iit.it
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

# This section sources the icub_basics.sh from icub interaction demos 
DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
echo sourcing $DEMOS_BASICS
source $DEMOS_BASICS


#######################################################################################
# "MAIN" DEMOS:                                                                    #
#######################################################################################
POSE_TIMING=10
CORRECTION_TIMING=4


go_home() {
    echo "set all hap" | yarp rpc /icub/face/emotions
    go_home_helper 3.0
    sleep 1.5

}

go_home_human(){

    echo "set all hap" | yarp rpc /icub/face/emotions/in
    breathers "stop"

    echo "ctpq time 2.0 off 0 pos (-1.4 15.8 16.0 15.0 -19.8 -0.32 -9.1 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-4.4 13.9 15.02 22.7 -6.7 -8.8 1.4 40.0 29.0 8.0 30.0 25.0 30.0 25.0 30.0 80.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc

    sleep 1.0
    echo "abs 0 -5 0" | yarp write ... /iKinGazeCtrl/angles:i
    breathers "start"

}

go_home_body() {

    echo "set all hap" | yarp rpc /icub/face/emotions
    go_home_body_helper 3.0
    sleep 1.5
}

go_home_body_helper() {
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms over the table
    go_home_helperR $1
    go_home_helperL $1
    go_home_helperT $1
    go_home_helperLL $1
    go_home_helperRL $1
}

go_home_helper() {
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms over the table
    go_home_helperR $1
    go_home_helperL $1
    go_home_helperH $1
    go_home_helperT $1
    go_home_helperLL $1
    go_home_helperRL $1
}

go_home_helperL(){
    # echo "ctpq time $1 off 0 pos (-30.0 36.0 0.0 60.0 0.0 0.0 0.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home_helperR(){
    # echo "ctpq time $1 off 0 pos (-30.0 36.0 0.0 60.0 0.0 0.0 0.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helperH(){
        echo "abs 0 -8 0" | yarp write ... /iKinGazeCtrl/angles:i
}

go_home_helperT(){
    echo "ctpq time $1 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
}

go_home_helperLL(){
        echo "ctpq time $1 off 0 pos (0.0 0.0 0.0 0.0 -0.17578167915449 0.258179341258157) " | yarp rpc /ctpservice/left_leg/rpc
}

go_home_helperRL(){
	echo "ctpq time $1 off 0 pos (0.0 0.0 0.0 0.0 -0.17578167915449 0.258179341258157) " | yarp rpc /ctpservice/right_leg/rpc
}


pointRightPose(){

	echo "ctpq time 2.0 off 0 pos (-22.28 46.99 -10.78 24.02 -59.60 7.50 -13.88 37.09 10.39 55.14 0.0 0.0 0.37 0.0 0.0 2.34)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 2.0 off 0 pos (15 0 0)" | yarp rpc /ctpservice/torso/rpc
    sleep 1.5
    go_home_helperR 2
    go_home_helperT 2
}

pointCenterPose(){

	echo "ctpq time 2.0 off 0 pos (-65.83 18.12 -7.82 14.98 -54.01 -0.37 1.04 41.40 60.48 56.0 1.87 0.0 0.0 0.0 0.37 0.46)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.5
    go_home_helperR 2
}

pointLeftPose(){

	echo "ctpq time 2.0 off 0 pos (-12.8 36.3 -15.8 39.2 -54.8 6.3 -12.8 34.0 10.3 25.7 0.37 30.48 50.2 42.6 2.9 27.37)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 2.0 off 0 pos (-13 0 0)" | yarp rpc /ctpservice/torso/rpc
    sleep 1.5
    go_home_helperL 2
    go_home_helperT 2
}

hello() {

    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc

    sleep 1.0

    go_home
}

happy() {
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


