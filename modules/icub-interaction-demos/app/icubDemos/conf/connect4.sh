#!/bin/bash



explaining_gesture_1() {
	echo "ctpq time 2.0 off 0 pos (-55.0 40-0 35.0 33.0 -50.0 -20.0 4.0 12.0 45.0 0.0 5.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
}

explaining_gesture_2() {
	echo "ctpq time 2.0 off 0 pos (-40.0 23-0 29.0 32.0 -50.0 -20.0 4.0 12.0 45.0 0.0 6.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home() {
	echo "ctpq time 2.0 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
}

thumb_up_gesture() {
	echo "ctpq time 2.0 off 0 pos (-44.0 36.0 54.0 91.0 -45.0 0.0 12.0 21.0 14.0 0.0 0.0 59.0 140.0 80.0 125.0 210.0)" | yarp rpc /ctpservice/left_arm/rpc
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
