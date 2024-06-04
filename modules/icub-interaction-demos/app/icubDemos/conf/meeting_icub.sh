#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Joshua Zonca, Anna Folso
# email:  joshua.zonca@iit.it
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
# meeting icub for Reciprocity experiment Folsoeee:                                   #
#######################################################################################

saluta_meet(){
    echo "ctpq time 1.5 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0 && speak "Ciao"
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
sleep 0.5    
echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0  25.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
sleep 0.5
    echo "ctpq time 0.3 off 0 pos (-60.0 44.0 -2.0 96.0 53.0 -17.0 -11.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
    smile
}

go_home
echo "sus" | yarp rpc /faceDetector/control/rpc

read -n 1 -s -r -p "Press any key to continue"

echo "ctpq time 2 off 0 pos (-33 0 -17)" | yarp rpc /ctpservice/torso/rpc
echo "abs -45 13 0.5" | yarp write ... /iKinGazeCtrl/angles:i
sleep 2.0
saluta_meet
sleep 1
go_home_helperR 2.0
echo "res" | yarp rpc /faceDetector/control/rpc

read -n 1 -s -r -p "Press any key to continue"

# wait tracker and enter iSpeak
speak "Piacere, io sono aicab."
sleep 3.0
speak "Ora faremo un gioco insieme."

read -n 1 -s -r -p "Press any key to continue"

speak "Io sono pronto! Buon divertimento! Ci vediamo dopo."
sleep 3.0
echo "sus" | yarp rpc /faceDetector/control/rpc

go_home


echo "ctpq time 1 off 0 pos (0 0 8)" | yarp rpc /ctpservice/torso/rpc
echo "ctpq time 2 off 0 pos (-56.0 23.0 5.2 44.0 60.0 -4.0 10.0 29.0 27.0 17.0 55.0 21.0 1.7 69.0 144.0 206.0)" | yarp rpc /ctpservice/right_arm/rpc









