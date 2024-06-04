#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Luca Garello, Linda Lastrico, Alice Nardelli, Giulia Pusceddu
# email:  luca.garello@iit.it, linda.lastrico@iit.it, giulia.pusceddu@iit.it
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
# "MAIN" DEMOS:                                                                    #
#######################################################################################

welcome(){
    #vedere il gesto di saluto
    speak "Ciao! Mi chiamo aicab. Ti insegno un gioco! si chiama, uno, due, tre, Jenga!"
    ciao_gesto
    sleep 2.0
}

rules_explanation(){

    speak "Avrai 4 raund per costruire una torre di mattoncini colorati." 
    sleep 4.0
    speak "Io chiuderò gli occhi e dirò Uno, due, tre, Jenga." 
    close_eyes
    sleep 5.0
    speak "Quando li riaprirò dovrai stare immobile."
    sleep 1.0
    open_eyes
    speak "Fai attenzione, mi raccomando... Se ti muoverai, dovrai rimuovere tre blocchetti dalla tua torre come penalità."
    cun
    warning_left_index 3.0
    sleep 4.0
    smile
    speak "Costruisci la torre più alta possibile! Iniziamo?"
    sleep 3.0
    open_both_arms 1.5
    sleep 1.0
    go_home
    sleep 1.0
}



countdown(){

    #gesto3
    echo "ctpq time 1.5 off 0 pos (-16.7 37.2 -21.2 98.3 27.6 -26.3 -15.1 10.1 10.0 9.7 14.3 18.0 0.4 22.2 0.0 264.3)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0
    speak "tre!"
    #gesto2
    sleep 1.0
    echo "ctpq time 1.5 off 0 pos (-16.7 37.2 -21.2 98.3 27.6 -26.3 -15.1 10.1 10.0 9.7 14.3 18.0 0.4 73.9 104.7 264.3)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0
    speak "due!"
    #gesto1
    sleep 1.0
    echo "ctpq time 1.5 off 0 pos (-16.7 37.2 -21.2 98.3 27.6 -26.3 -15.1 10.1 10.0 33.6 93.5 18.0 0.4 73.9 104.7 264.3)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0
    speak "uno!"
    #gesto via
    sleep 1.0
    echo "ctpq time 1.0 off 0 pos (-16.7 37.2 -21.2 98.3 27.6 -26.3 -15.1 10.7 28.5 8.0 30.0 1.8 -0.4 3.6 3.6 18.5)" | yarp rpc /ctpservice/right_arm/rpc
    speak "Via!"
    sleep 1.0
    go_home
}

counting(){
    
    #chiudo mani
    echo "ctpq time 3.0 off 0 pos (-68.47 18.74 26.19 95.41 -57.60 12.11 -5.81 40.09 14.53 1.22 0.0 0.0 0.0 0.0 0.74 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 3.0 off 0 pos (-63.55 15.69 1.80 102.30 -54.81 24.98 19.16 23.02 26.89 0.0 0.0 0.0 0.0 0.0 2.18 0.47)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 1.0    
    close_eyes    
    speak "uno"
    num=$((1 + $RANDOM % 5))
    sleep $num
    speak "due"
    num=$((1 + $RANDOM % 5))
    sleep $num
    speak "tre"
    num=$((1 + $RANDOM % 4))
    sleep $num
    open_eyes
    speak "Jenga!!"         
    go_home
}

counting_eyes(){

    close_eyes
    sleep 1.0    
    speak "uno"
    num=$((1 + $RANDOM % 5))
    sleep $num
    speak "due"
    num=$((1 + $RANDOM % 5))
    sleep $num
    speak "tre"
    num=$((1 + $RANDOM % 4))
    sleep $num
    open_eyes
    speak "Jenga!!"    
    sleep 0.1

}

eyes_open(){
   sleep 0.1
}

end_game(){
    pointing_up_arm_left 2.0
    sleep 1.0
    speak "Stop! Raund terminati! Fine del Gioco!"    
    sleep 1.0     
    go_home
}

goodbye(){
    smile
    speak "Mi sono divertito a giocare con te! Alla prossima sfida!"
    sleep 3.0
    dabbing_left
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

