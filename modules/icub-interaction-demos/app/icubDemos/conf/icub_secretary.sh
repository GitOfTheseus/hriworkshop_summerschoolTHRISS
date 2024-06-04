#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Francesco Rea, Gonzalez Jonas, Giulia Belgiovine
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



go_home() {
    echo "set all hap" | yarp rpc /icub/face/emotions/in

    go_home_helper 3.0
    sleep 1.5

}

go_home_helper() {
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms over the table
    echo "set all hap" | yarp rpc /icub/face/emotions/in    
    go_home_helperR $1
    go_home_helperL $1
    go_home_helperH $1
    go_home_helperT $1
}


go_home_helperL()
{

    echo "ctpq time $1 off 0 pos (6.0 13.0 0.0 31.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home_helperR()
{

    echo "ctpq time $1 off 0 pos (6.0 13.0 0.0 29.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helperH()
{
        echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0) 
}

go_home_helperT()
{
    echo "ctpq time $1 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
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

