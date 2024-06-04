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

# Eventually include other scripts using the aboslute path. IN THIS WAY YOU INHERIT THOSE FUNCTIONS.
DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
echo sourcing $DEMOS_BASICS
source $DEMOS_BASICS

#######################################################################################
# "MAIN" DEMOS:                                                                       #
#######################################################################################

# PUT HERE YOUR DEMO #
staticExt(){
  # This action moves the robot in a rest position, with both arms slightly forward and with the hands slightly closed.
	smile
        echo "ctpq time 2.5 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 2.5 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 2.5 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i
    	
}

staticInt(){
  # This action moves the robot in a rest position, with both arms slightly forward and with the hands slightly closed.
	neutral
        echo "ctpq time 2.5 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time 2.5 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
	echo "ctpq time 2.5 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i
    	
}


museumExt(){
    smile
    speak "\\\rspd=130\\\ \\\vct=120\\\ Non avevo mai notato quanto fosse bello il palazzo del museo"
    echo "ctpq time 2.5 off 0 pos (-56.769231 23.901099 52.663077 44.989011 -50.079599 -20.967033 -4.175824 11.0 45.05 0.379687 3.933405 -0.432335 -0.8783 0.111111 1.269548 -8.225263)" | yarp rpc /ctpservice/left_arm/rpc
    echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    neutral
    staticExt
}

paninoExt(){
    smile
    speak "Uh guarda la! che voglia ho di mangiare un panino adesso. Yummy!"
    sleep 2.0
    echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    staticExt
}

redLightExt(){
    surprised
    sleep 2.0 
    angry
    speak "Attento sei passato con il rosso"
    angry
    echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0 
    echo "abs -8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    staticExt
}

bumpingExt(){
    
    speak "potevi fare del male a qualcuno!"
    sleep 2.0
    angry
    sleep 2.0
    staticExt
}

speedyExt(){
    speak "Ti piace la velocita allora"
    smile
}

fireExt(){
    surprised
    sleep 2.0
    speak "Oh guarda ci sono i pompieri, speriamo non ci siano stati incidenti"
    sleep 2.0
    surprised
    sleep 2.0
    staticExt
}

movesExt(){

	echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
	sleep 2.0
	echo "abs -8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    smile
	sleep 3.0 
	echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
	sleep 2.0 
	echo "abs -8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    
}
whistleExt(){
    surprised
    echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
	sleep 2.0
    speak "Uuuuuuu"
	echo "abs -8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    smile	
    sleep 3.0
}

museumInt(){
    neutral
    speak "\\\rspd=95\\\ \\\vct=90\\\ Ho visto lo spettacolo su Michelangelo, è stato molto interessante"
    sleep 2.0
    echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    echo "abs -10 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    
    staticInt
}

cityInt(){
    smile
    speak "Non sono mai stato in una cittá cosí bella"
    echo "abs 0.5 11 0.5 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    echo "abs 0.5 -11 0.5 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    staticInt
}

redLightInt(){
    surprised
    speak "Cosa stai facendo? Infrangi il codice della strada!"
    angry
    echo "abs 8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0 
    echo "abs -8 0.5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    staticInt
}

bumpingInt(){
    angry
    speak "Stai attento! se continui così chiamerò la polizia!"
    sleep 2.0
    angry
    sleep 2.0
    staticInt
}

speedyInt(){
    speak "Guidi troppo velocemente"
    sad
    sleep 2.0
    staticInt
}

pedestrianInt(){
    neutral
    sleep 2.0
    speak "Rallenta!, c'è un pedone che attraversa la strada"
    sleep 2.0
    sad
    sleep 2.0
    staticInt
}

movesInt(){
    echo "abs 0.5 -11 0.5 " | yarp write ... /iKinGazeCtrl/angles:i
	sleep 2.0
	echo "abs -8 5 8 " | yarp write ... /iKinGazeCtrl/angles:i
    
    neutral
	sleep 3.0 
	echo "abs 0.5 -11 0.5 " | yarp write ... /iKinGazeCtrl/angles:i
	sleep 2.0 
	echo "abs -8 5 8" | yarp write ... /iKinGazeCtrl/angles:i
    sleep 2.0
    staticInt
}

#######################################################################################
# "MAIN" FUNCTION: **leave like that**                                                 #
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

