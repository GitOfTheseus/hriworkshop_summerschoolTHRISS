#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Fabio Vannucci
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

DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
DEMOS_CROCODILE=$(yarp resource --context icubDemos --find icub_crocodile_dance.sh | grep -v 'DEBUG' | tr -d '"')

echo sourcing $DEMOS_BASICS
echo sourcing $DEMOS_CROCODILE 
source $DEMOS_BASICS
source $DEMOS_CROCODILE

#######################################################################################
# "MAIN" DEMOS:                                                                    #
#######################################################################################

nod() {
    
    echo "ctpq time 0.40 off 0 pos (5.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.50 
    echo "ctpq time 0.40 off 0 pos (-5.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.50
    echo "ctpq time 0.40 off 0 pos (5.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.50

    echo "ctpq time 0.40 off 0 pos (-0.1 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc


}

shake() {
    
    echo "ctpq time 0.40 off 0 pos (0.0 0.0 -4.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.40
    echo "ctpq time 0.40 off 0 pos (0.0 0.0 4.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.40
    echo "ctpq time 0.40 off 0 pos (0.0 0.0 -4.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.40
    echo "ctpq time 0.40 off 0 pos (0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/head/rpc
    sleep 0.40


}

blink() {
    
    echo "blink" | yarp rpc /iCubBlinker/rpc

}

nod_1() {
   nod
   sleep 0.9
   speak "a"
   nod
   sleep 1.0
   nod
   sleep 1.0
}

nod_2() {
   nod
   sleep 0.9
   speak "a,a"
   nod
   sleep 1.0
   nod
   sleep 1.0
}


shake_1() {
   shake
   sleep 0.9
   speak "a"
   shake
   sleep 1.0
   shake
   sleep 1.0
}

shake_2() {
   shake
   sleep 0.9
   speak "a,a"
   shake
   sleep 1.0
   shake
   sleep 1.0
}


nod_blink() {
   speak ", aaaa,aaaa"
   nod
   sleep 3.0
   blink
   sleep 3.0
   speak ", aaaa,aaaa"
   nod
   
}

shake_blink() {
   speak ", aaaa,aaaa"
   shake
   sleep 3.0
   blink
   sleep 3.0
   speak ", aaaa,aaaa"
   shake
   
}

base_blink() {
   speak "aaaa,aaaa"
   sleep 3.0
   blink
   sleep 3.0
   speak "aaaa,aaaa"
   
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

