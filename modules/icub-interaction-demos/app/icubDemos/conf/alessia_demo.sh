#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Francesco Rea, Alessia vignolo
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
# ALESSIA JOHN DEMO FUNCTIONS:                                                        #
#######################################################################################

#######################################################################################
#FOR VIDEO ON TASK WITH OR WITHOUT COLLABORATION WITH ICUB
#######################################################################################

gaze_reaching1() {  
    #echo "ctpq time $1 off 0 pos (-1.538462 -1.56044 -17.988901 -16.21978 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 0 pos (-17.1868131868132 1.16483516483515 13.4836263736264 -19.8241758241758 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
reaching1() {  
    echo "ctpq time $1 off 0 pos (-28.450549 32.186813 0.018242 44.989011 37.200178 -5.054945 1.274725 23.24875 56.471194 2.389529 2.909729 33.42341 28.473077 46.803456 20.515662 0)" | yarp rpc /ctpservice/right_arm/rpc    #last one: -1.83908
    #echo "ctpq time $1 off 0 pos (-17.1868131868132 1.16483516483515 -16.2306593406593 -19.8241758241758 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 0 pos (-50.032967 13.846154 9.186813)" | yarp rpc /ctpservice/torso/rpc
}
reaching1_gaze() {  
    echo "ctpq time 1 off 0 pos (-17.1868131868132 1.16483516483515 -16.2306593406593 -19.8241758241758 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
    #echo "ctpq time 1 off 0 pos (-28.450549 32.186813 0.018242 44.989011 37.200178 -5.054945 1.274725 23.24875 56.471194 2.389529 2.909729 33.42341 28.473077 46.803456 20.515662 -1.83908)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1 off 0 pos (-28.4505494505495 32.1868131868132 0.0182417582417429 48.4175824175824 37.2001783010457 -5.23076923076923 1.1868131868132 24.1911579013733 10 4.53269181311616 3.27139240506332 13.7134808478989 28.8576923076923 24.1252699784017 10.3983002832861 5.63218390804599)" | yarp rpc /ctpservice/right_arm/rpc
     echo "ctpq time 1 off 0 pos (-50.032967032967 13.8461538461538 4.61538461538461)" | yarp rpc /ctpservice/torso/rpc
     #echo "ctpq time 1 off 0 pos (-50.032967 13.846154 9.186813)" | yarp rpc /ctpservice/torso/rpc
}
reaching1_gaze_grasping() {  
    echo "ctpq time 0.5 off 0 pos (-50.032967032967 13.8461538461538 11.1208791208791)" | yarp rpc /ctpservice/torso/rpc    
    echo "ctpq time 1 off 0 pos (-28.4505494505495 32.1868131868132 0.106153846153831 48.4175824175824 37.2001783010457 -5.05494505494505 1.27472527472528 24.1911579013733 56.5117902813299 4.10405915130734 1.10141048824596 47.9269431015247 41.55 61.2023038156947 34.2752731687576 9.65517241379308)" | yarp rpc /ctpservice/right_arm/rpc
#echo "ctpq time 1 off 0 pos (-50.032967 13.846154 9.186813)" | yarp rpc /ctpservice/torso/rpc
}
reaching1_gazeathuman_grasping() {  
    echo "ctpq time 0.5 off 0 pos (-50.032967032967 13.8461538461538 11.1208791208791)" | yarp rpc /ctpservice/torso/rpc    
    echo "ctpq time 1 off 0 pos (-28.4505494505495 32.1868131868132 0.106153846153831 48.4175824175824 37.2001783010457 -5.05494505494505 1.27472527472528 24.1911579013733 56.5117902813299 4.10405915130734 1.10141048824596 47.9269431015247 41.55 61.2023038156947 34.2752731687576 9.65517241379308)" | yarp rpc /ctpservice/right_arm/rpc
#echo "ctpq time 1 off 0 pos (-50.032967 13.846154 9.186813)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 1 off 0 pos (-17.1868131868132 1.16483516483515 -16.2306593406593 -19.8241758241758 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}

#releasing0() {  #inutile
#    echo "ctpq time 3 off 0 pos (-47.043956 2.417582 3.648352)" | yarp rpc /ctpservice/torso/rpc
#}
gaze_releasing1() {  
    #echo "ctpq time $1 off 0 pos (-1.538462 -1.56044 -17.988901 -16.21978 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 0 pos (-16.1318681318681 15.5824175824176 -44.9779120879121 -19.8241758241758 20.9992619884686 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
gaze_releasing1_2obj() {  
    echo "ctpq time $1 off 0 pos (-3.12087912087912 7.58241758241758 -44.9779120879121 -19.8241758241758 20.9992619884686 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}

gaze_releasing2() {  
    echo "ctpq time $1 off 0 pos (-1.53846153846155 -1.56043956043956 -44.9779120879121 -22.1978021978022 29.9994026156659 9.00063929123893)" | yarp rpc /ctpservice/head/rpc
}
releasing0() {  
    echo "ctpq time $1 off 0 pos (-48.978021978022 9.01098901098902 20.2637362637363)" | yarp rpc /ctpservice/torso/rpc
}
releasing1() {  
    echo "ctpq time $1 off 0 pos (49.043956 2.417582 -8)" | yarp rpc /ctpservice/torso/rpc
}
releasing1_gaze() {  
    echo "ctpq time 1.3 off 0 pos (49.043956 2.417582 -8)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 0.5 off 0 pos (-16.1318681318681 15.5824175824176 -44.9779120879121 -19.8241758241758 7.19670257347771 4.99276416819013)" | yarp rpc /ctpservice/head/rpc
}
#releasing1b() {  
#    echo "ctpq time 5 off 0 pos (-46.384615 54.692308 46.26 54.571429 37.200178 -5.230769 1.274725 22.934613 56.795962 1.960896 28.949512 33.42341 28.088462 46.803456 19.706273 -0.689655)" | yarp rpc /ctpservice/right_arm/rpc
#}
releasing2() {  
    echo "ctpq time $1 off 0 pos (-46.384615 54.692308 46.172088 18.527473 37.200178 10.505495 -1.274725 23.562886 56.795962 -1.468165 26.77953 33.051525 28.473077 48.963283 20.920356 -0.114943)" | yarp rpc /ctpservice/right_arm/rpc
    #echo "ctpq time 3 off 0 pos (-15.076923 -2.791209 -38.648242 -15.604396 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
}
releasing2_obj2() {  
    echo "ctpq time $1 off 0 pos (-46.384615 54.692308 46.172088 18.527473 37.200178 10.505495 -1.274725 53.4058178931499 73.968048146795 37.1087741105872 -3.23855334538877 25.9857010040907 33.0884615384616 15.1259899208063 34.6799676244435 70.0)" | yarp rpc /ctpservice/right_arm/rpc
}

releasing3() {  
    echo "ctpq time $1 off 0 pos (-46.384615 54.692308 46.172088 18.527473 37.200178 10.505495 -1.274725 23.24875 48.79856 -0.6109 1.824738 -0.046281 0.011538 0.007199 21.325051 0.45977)" | yarp rpc /ctpservice/right_arm/rpc
}
rotating_for_grasping() {  
    echo "ctpq time $1 off 0 pos (-30.043956 29.967033 0.003736 44.989011 0.000354 -0.043956 0.043956 15.0 44.9 -0.402786 12.049594 -1.310299 0.399928 0.111111 4.678155 -2.326897)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $1 off 0 pos (-50.032967 2.417582 3.648352)" | yarp rpc /ctpservice/torso/rpc
}
gaze_reaching2() {  
    #echo "ctpq time $1 off 0 pos (-1.538462 -1.56044 -17.988901 -16.21978 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 0 pos (-19.2967032967033 -1.20879120879121 33.2638461538462 -21.0549450549451 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
gaze_reaching3() {  
    #echo "ctpq time $1 off 0 pos (-1.538462 -1.56044 -17.988901 -16.21978 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 0 pos (-18.7692307692308 -3.23076923076923 24.2968131868132 -21.0549450549451 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
reaching2() {  
    echo "ctpq time 1.8 off 0 pos (-54.8241758241758 33.7692307692308 46.1720879120879 54.5714285714286 37.2001783010457 -6.28571428571428 1.62637362637363 57.8037236983636 74.455199529087 -0.182267466780957 30.7578300180832 20.4074191149126 13.4730769230769 0.00719942404607821 21.7297450424929 0.459770114942501)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-49.9450549450549 9.62637362637363 22.989010989011)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 1.8 off 0 pos (-1.53846153846155 -1.56043956043956 -4.53835164835164 -16.2197802197802 0.000105751652370145 9.00063929123893)" | yarp rpc /ctpservice/head/rpc

    #echo "ctpq time $1 off 0 pos (-54.824176 33.769231 46.172088 54.659341 37.200178 -5.230769 1.186813 22.620477 56.836558 -0.6109 32.204485 33.42341 28.473077 46.803456 20.110967 -1.264368)" | yarp rpc /ctpservice/right_arm/rpc
    #echo "ctpq time $1 off 0 pos (-50.032967 16.835165 16.571429)" | yarp rpc /ctpservice/torso/rpc
    #echo "ctpq time $1 off 0 pos (-1.538462 -1.56044 -4.538352 -16.21978 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
}
reaching2_gaze() {  
    echo "ctpq time 1.8 off 0 pos (-54.8241758241758 33.7692307692308 46.1720879120879 54.5714285714286 37.2001783010457 -6.28571428571428 1.62637362637363 57.8037236983636 10 -0.182267466780957 30.7578300180832 20.4074191149126 13.4730769230769 0.00719942404607821 21.7297450424929 0.459770114942501)" | yarp rpc /ctpservice/right_arm/rpc
    #echo "ctpq time 2 off 0 pos (-49.9450549450549 9.62637362637363 22.989010989011)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 2 off 0 pos (-49.9450549450549 9.45054945054946 16.3956043956044)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 1 off 0 pos (-1.53846153846155 -1.56043956043956 -4.53835164835164 -16.2197802197802 0.000105751652370145 9.00063929123893)" | yarp rpc /ctpservice/head/rpc

    #echo "ctpq time $1 off 0 pos (-54.824176 33.769231 46.172088 54.659341 37.200178 -5.230769 1.186813 22.620477 56.836558 -0.6109 32.204485 33.42341 28.473077 46.803456 20.110967 -1.264368)" | yarp rpc /ctpservice/right_arm/rpc
    #echo "ctpq time $1 off 0 pos (-50.032967 16.835165 16.571429)" | yarp rpc /ctpservice/torso/rpc
    #echo "ctpq time $1 off 0 pos (-1.538462 -1.56044 -4.538352 -16.21978 0.000106 9.000639)" | yarp rpc /ctpservice/head/rpc
}

reaching2_gaze_grasping() { 
    echo "ctpq time 0.5 off 0 pos (-49.9450549450549 9.62637362637363 22.989010989011)" | yarp rpc /ctpservice/torso/rpc 
    echo "ctpq time 1.8 off 0 pos (-54.8241758241758 33.7692307692308 45.9962637362637 54.5714285714286 39.6001669803444 10.5934065934066 1.71428571428572 53.4058178931499 73.968048146795 37.1087741105872 -3.23855334538877 25.9857010040907 33.0884615384616 15.1259899208063 34.6799676244435 70.0)" | yarp rpc /ctpservice/right_arm/rpc
}
reaching2_gazeathuman_grasping() { 
    echo "ctpq time 0.5 off 0 pos (-49.9450549450549 9.62637362637363 22.989010989011)" | yarp rpc /ctpservice/torso/rpc 
    echo "ctpq time 1.8 off 0 pos (-1.53846153846155 -1.56043956043956 -4.53835164835164 -16.2197802197802 0.000105751652370145 9.00063929123893)" | yarp rpc /ctpservice/head/rpc 
    echo "ctpq time 1.8 off 0 pos (-54.8241758241758 33.7692307692308 45.9962637362637 54.5714285714286 39.6001669803444 10.5934065934066 1.71428571428572 53.4058178931499 73.968048146795 37.1087741105872 -3.23855334538877 25.9857010040907 33.0884615384616 15.1259899208063 34.6799676244435 70.0)" | yarp rpc /ctpservice/right_arm/rpc
}
reaching3() {  
    echo "ctpq time 1.4 off 0 pos (-66.4285714285714 43.4395604395604 46.1720879120879 37.0769230769231 37.2001783010457 -6.28571428571428 1.62637362637363 57.8037236983636 74.2928157349897 -0.61090012858979 30.3961663652803 21.1511900334697 14.2423076923077 0.00719942404607821 21.7297450424929 3.33333333333331)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-50.032967032967 8.92307692307693 22.989010989011)" | yarp rpc /ctpservice/torso/rpc
    #echo "ctpq time 1.8 off 0 pos (-1.53846153846155 -1.56043956043956 -4.53835164835164 -16.2197802197802 0.000105751652370145 9.00063929123893)" | yarp rpc /ctpservice/head/rpc
}
reaching3_gaze() {  
    echo "ctpq time 1.7 off 0 pos (-66.4285714285714 43.4395604395604 46.1720879120879 37.0769230769231 37.2001783010457 -6.28571428571428 1.62637362637363 57.8037236983636 10 -0.61090012858979 30.3961663652803 21.1511900334697 14.2423076923077 0.00719942404607821 21.7297450424929 3.33333333333331)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-50.032967032967 8.92307692307693 22.989010989011)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 1 off 0 pos (-1.53846153846155 -1.56043956043956 -20.8020879120879 -18.5934065934066 0.000105751652370145 9.00063929123893)" | yarp rpc /ctpservice/head/rpc
}
reaching3_gaze_grasping() {  
    echo "ctpq time 1.7 off 0 pos (-66.4285714285714 43.4395604395604 46.1720879120879 37.0769230769231 37.2001783010457 4.17582417582418 1.62637362637363 24.1911579013733 56.5117902813299 4.10405915130734 1.10141048824596 47.9269431015247 41.55 61.2023038156947 34.2752731687576 9.65517241379308)" | yarp rpc /ctpservice/right_arm/rpc
}
gaze_reaching4() {  
    echo "ctpq time $1 off 0 pos (-16.1318681318681 15.5824175824176 -20 -19.8241758241758 -6.194873857404 5.00331120798763)" | yarp rpc /ctpservice/head/rpc
}
reaching4_gaze() {  
    echo "ctpq time 1.7 off 0 pos (-87.5274725274725 56.3626373626374 46.1720879120879 15.010989010989 37.2001783010457 12.6153846153846 1.62637362637363 55.6047707957567 10 -1.03953279039862 29.6728390596745 21.1511900334697 14.2423076923077 0.00719942404607821 21.325050586807 53.9080459770115)" | yarp rpc /ctpservice/right_arm/rpc
    #echo "ctpq time 2 off 0 pos (-50.032967032967 8.39560439560441 29.4945054945055)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 2 off 0 pos (-50.032967032967 8.4835164835165 24.9230769230769)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 0.5 off 0 pos (-8.83516483516485 5.56043956043956 -42.2526373626374 -19.8241758241758 1.80189171705808 4.98924848825763)" | yarp rpc /ctpservice/head/rpc
    #echo "ctpq time 0.5 off 0 pos (8.30769230769232 -8.76923076923077 -44.9779120879121 9.62637362637363 30.0046761355646 0.510272254253973)" | yarp rpc /ctpservice/head/rpc
}
reaching4_gaze_grasping() {  
    echo "ctpq time 1.7 off 0 pos (-87.5274725274725 56.3626373626374 46.1720879120879 15.010989010989 37.2001783010457 12.6153846153846 1.62637362637363 24.1911579013733 56.5117902813299 4.10405915130734 1.10141048824596 47.9269431015247 41.55 61.2023038156947 34.2752731687576 9.65517241379308)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-50.032967032967 8.39560439560441 29.4945054945055)" | yarp rpc /ctpservice/torso/rpc

}
reaching4_gazeathuman_grasping() {  
    echo "ctpq time 1.7 off 0 pos (-87.5274725274725 56.3626373626374 46.1720879120879 15.010989010989 37.2001783010457 12.6153846153846 1.62637362637363 24.1911579013733 56.5117902813299 4.10405915130734 1.10141048824596 47.9269431015247 41.55 61.2023038156947 34.2752731687576 9.65517241379308)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (-50.032967032967 8.39560439560441 29.4945054945055)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 2 off 0 pos (-8.83516483516485 5.56043956043956 -42.2526373626374 -19.8241758241758 1.80189171705808 4.98924848825763)" | yarp rpc /ctpservice/head/rpc
}
gaze_waiting_for_object() {  
    echo "ctpq time $1 off 0 pos (-16.0439560439561 10.8351648351648 -22.1097802197802 -19.8241758241758 7.19670257347771 4.99276416819013)" | yarp rpc /ctpservice/head/rpc
}
waiting_for_object() {  
    echo "ctpq time $1 off 0 pos (-6.03296703296704 23.043956043956 -5.08065934065934 65.9120879120879 -58.7993688709016 -5.23076923076923 0.835164835164846 29.2173359644747 28.5817776965859 13.1053450492928 27.5028571428572 33.4234101896616 42.3192307692308 25.565154787617 46.4161068393363 108.505747126437)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $1 off 0 pos (-3.0 0.043956043956058 0.043956043956058)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time $1 off 0 pos (-19.2967032967033 0.373626373626365 -33.2856043956044 -17.4505494505495 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
waiting_for_object_grasping() {  
    echo "ctpq time $1 off 0 pos (-6.03296703296704 23.043956043956 -5.08065934065934 65.9120879120879 -58.7993688709016 -5.23076923076923 0.835164835164846 28.9031998355309 28.8253533877319 5.38995713673383 26.0562025316456 46.4394012644106 55.0115384615385 33.8444924406048 50.0583569405099 151.034482758621)" | yarp rpc /ctpservice/right_arm/rpc
 }
waiting_for_object_gaze() {  
    echo "ctpq time 0.5 off 0 pos (-16.0439560439561 10.8351648351648 -33.2856043956044 -19.8241758241758 7.19670257347771 4.99276416819013)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 1.2 off 0 pos (-6.03296703296704 23.043956043956 -5.08065934065934 65.9120879120879 -58.7993688709016 -5.23076923076923 0.835164835164846 29.2173359644747 28.5817776965859 13.1053450492928 27.5028571428572 33.4234101896616 42.3192307692308 25.565154787617 46.4161068393363 108.505747126437)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.2 off 0 pos (-3.0 0.043956043956058 0.043956043956058)" | yarp rpc /ctpservice/torso/rpc
    #echo "ctpq time 0.5 off 0 pos (-19.2967032967033 0.373626373626365 -33.2856043956044 -17.4505494505495 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}



gaze_waiting_for_object_athuman() {  
    echo "ctpq time $1 off 0 pos (-5.67032967032966 5.91208791208791 -22.1207692307692 0.571428571428584 -10.1953660525946 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
waiting_for_object_gaze_athuman() {  
    echo "ctpq time 0.7 off 0 pos (21.3186813186813 0.0219780219780148 -4.53835164835164 4.17582417582418 7.19670257347771 4.99276416819013)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time 1.2 off 0 pos (-6.03296703296704 23.043956043956 -5.08065934065934 65.9120879120879 -58.7993688709016 -5.23076923076923 0.835164835164846 29.2173359644747 28.5817776965859 13.1053450492928 27.5028571428572 33.4234101896616 42.3192307692308 25.565154787617 46.4161068393363 108.505747126437)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 1.2 off 0 pos (-3.0 0.043956043956058 0.043956043956058)" | yarp rpc /ctpservice/torso/rpc
    #echo "ctpq time 0.5 off 0 pos (-19.2967032967033 0.373626373626365 -33.2856043956044 -17.4505494505495 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
waiting_for_object_grasping_athuman() {  
    echo "ctpq time $1 off 0 pos (-6.03296703296704 23.043956043956 -5.08065934065934 65.9120879120879 -58.7993688709016 -5.23076923076923 0.835164835164846 28.9031998355309 28.8253533877319 5.38995713673383 26.0562025316456 46.4394012644106 55.0115384615385 33.8444924406048 50.0583569405099 151.034482758621)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $1 off 0 pos (4.7032967032967 0.0219780219780148 -22.4724175824176 -24.0439560439561 7.19670257347771 4.99276416819013)" | yarp rpc /ctpservice/head/rpc
}

grasping_fault() {  #open hand
    echo "ctpq time $1 off 0 pos (-48.5054945054945 44.6483516483516 0.0916483516483524 74.0879120879121 -58.7993688709016 0.043956043956058 0.043956043956058 15.25 89.6 1.16215962441315 11.1952584365656 0.445627743634759 0.399927567106943 0.481481481481481 4.6781550916063 -6.86410163339383)" | yarp rpc /ctpservice/left_arm/rpc
}
grasping_fault2() { #to close hand on the fault   
    echo "ctpq time $1 off 0 pos (-48.5054945054945 44.6483516483516 0.00373626373626479 74.0879120879121 -58.7993688709016 -0.043956043956058 -0.043956043956058 15.0 89.7 -1.18525821596243 49.2131994873986 0.00664618086040036 102.232053685556 -0.259259259259252 97.9887643800596 73.4444283121597)" | yarp rpc /ctpservice/left_arm/rpc
}
athuman(){
    echo "ctpq time $1 off 0 pos (-15.0769230769231 2.83516483516485 -44.9779120879121 0.571428571428584 29.9994026156659 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
athuman_b(){
    echo "ctpq time $1 off 0 pos (-15.0769230769231 2.83516483516485 -44.9779120879121 10.7692307692308 29.9994026156659 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}
athuman2(){
    echo "ctpq time $1 off 0 pos (8.30769230769232 -8.76923076923077 -44.9779120879121 9.62637362637363 30.0046761355646 0.510272254253973)" | yarp rpc /ctpservice/head/rpc
}
athuman3(){
    echo "ctpq time $1 off 0 pos (-1.53846153846155 -1.56043956043956 -44.9779120879121 11.3846153846154 29.9994026156659 9.00063929123893)" | yarp rpc /ctpservice/head/rpc
}
lookathuman(){
    echo "ctpq time 1 off 0 pos (21.8461538461538 0.0219780219780148 -11.6592307692308 7.16483516483515 0.000105751652370145 4.99979552805513)" | yarp rpc /ctpservice/head/rpc
}


grasping_releasing_sequence() {  
    go_home
    grasping_fault 2
    reaching1 2
    sleep 1
    releasing1 3
    sleep 1
    releasing2 3
    sleep 2
    releasing3 0.2
    sleep 1
    reaching2 3
    sleep 1
    releasing1 3
    sleep 1
    releasing2 3 
    sleep 2
    releasing3 0.2
    sleep 1
    reaching2 3
    sleep 1
    releasing1 3
    sleep 1
    releasing2 3 
    sleep 2
    releasing3 0.2
    sleep 1
}

grasping_releasing_sequence_fast() {  
    go_home
    grasping_fault 2
    sleep 2
    gaze_reaching1 1
    sleep 0.4
    reaching1 1
    sleep 0.4
    gaze_releasing1 1
    releasing1 2
    releasing2 1.3
    releasing3 0.1
    sleep 1.6
    gaze_reaching2 1
    #sleep 0.4
    reaching2 2
    sleep 0.4
    gaze_releasing2 1
    releasing1 2
    releasing2 1.3
    releasing3 0.1
    sleep 1.6



    #sleep 1
    #reaching2 2
    #sleep 1
    #releasing1 2
    #sleep 1
    #releasing2 1.5
    #sleep 1
    #releasing3 0.1
    #sleep 1
    #reaching2 2
}
	
releasing_sequence() {  
    go_home
    grasping_fault 2
    #reaching1 2
    #sleep 1
    releasing1 3
    sleep 1
    releasing2 3
    sleep 2
    releasing3 0.2
    sleep 1
    go_home #reaching2 3
    sleep 1
    releasing1 3
    sleep 1
    releasing2 3 
    sleep 2
    releasing3 0.2
    sleep 1
    go_home #reaching2 3
    sleep 1
    releasing1 3
    sleep 1
    releasing2 3 
    sleep 2
    releasing3 0.2
    sleep 1
}

















noncoll_nogaze(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4
    reaching1 1
    releasing1 1.3 #2
    releasing2 1.3 #1.3
    releasing3 0.1 #0.1
    reaching2 
    releasing1 1.3 #2
    releasing2 1.3 #1.3
    releasing3 0.1 #0.1
    reaching3
    releasing1 1.3 #2
    sleep 8
    releasing2 1.3 #1.3
    releasing3 0.1 #0.1
}

noncoll_gaze(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4

    gaze_reaching1 1
    sleep 1
    reaching1_gaze

    gaze_releasing1 0.5
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_reaching2 1
    reaching2_gaze 

    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_reaching3 1
    reaching3_gaze


    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
}

noncoll_gaze_grasping(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4

    gaze_reaching1 1
    sleep 1
    reaching1_gaze
    sleep 12
    reaching1_gaze_grasping
    sleep 12
    gaze_releasing1 0.5
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_reaching2 1
    reaching2_gaze 
    sleep 12
    reaching2_gaze_grasping
    sleep 12

    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1


    gaze_reaching4 0.7
    reaching4_gaze
    sleep 12
    reaching4_gaze_grasping
    sleep 12

    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1





    gaze_reaching3 1
    reaching3_gaze
    ##sleep 4
    ##reaching3_gaze_grasping
    ##sleep 4 

    ##gaze_releasing1_2obj 0.8
    ##releasing1_gaze #1.3
    ##releasing2 1.3
    ##releasing3 0.1
}
go_home_collnoncoll(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4
}

noncoll_gaze_grasping2(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4

    gaze_reaching1 1
    sleep 1
    reaching1_gaze
    sleep 8
    reaching1_gaze_grasping
    sleep 12
    gaze_releasing1 0.5
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1




    gaze_reaching4 0.7
    reaching4_gaze
    sleep 8
    reaching4_gaze_grasping
    sleep 12

    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1





    gaze_reaching2 1
    reaching2_gaze 
    sleep 8
    reaching2_gaze_grasping
    sleep 12
    
    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1

    gaze_reaching3 1
    reaching3_gaze




    ##sleep 4
    ##reaching3_gaze_grasping
    ##sleep 4 

    ##gaze_releasing1_2obj 0.8
    ##releasing1_gaze #1.3
    ##releasing2 1.3
    ##releasing3 0.1
}

noncoll_gazeathuman_grasping2(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4

    gaze_reaching1 1
    sleep 1
    reaching1_gaze
    athuman 1
    sleep 8
    reaching1_gazeathuman_grasping
    sleep 12
    gaze_releasing1 0.5
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1




    gaze_reaching4 0.7
    reaching4_gaze
    sleep 3
    athuman2 1
    sleep 8
    reaching4_gazeathuman_grasping
    sleep 12

    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1





    gaze_reaching2 1
    reaching2_gaze 
    sleep 3
    athuman3 1
    sleep 8
    reaching2_gazeathuman_grasping
    sleep 12
    
    gaze_releasing1_2obj 0.8
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1

    gaze_reaching3 1
    reaching3_gaze




    ##sleep 4
    ##reaching3_gaze_grasping
    ##sleep 4 

    ##gaze_releasing1_2obj 0.8
    ##releasing1_gaze #1.3
    ##releasing2 1.3
    ##releasing3 0.1
}



coll_nogaze(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4
    waiting_for_object 1.2
    sleep 1
    releasing1 1.2
    releasing2 1.2
    sleep 0.3
    releasing3 0.1
    sleep 1
    waiting_for_object 1.2
    sleep 1
    releasing1 1.2
    releasing2 1.2
    sleep 0.3
    releasing3 0.1
    sleep 1
    waiting_for_object 1.2
    sleep 1
    releasing1 1.2
    releasing2 1.2
    sleep 0.3
    releasing3 0.1
    sleep 1
    waiting_for_object 1.2 
}


coll_gaze(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4
    waiting_for_object 1.2
    sleep 3


    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    sleep 3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    sleep 3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    sleep 3


    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    sleep 1.5

    #releasing1 1.2
    #releasing2 1.2
    #sleep 0.3
    #releasing3 0.1
    #sleep 1
    #waiting_for_object 1.2
    #sleep 1
    #releasing1 1.2
    #releasing2 1.2
    #sleep 0.3
    #releasing3 0.1
    #sleep 1
    #waiting_for_object 1.2
    #sleep 1
    #releasing1 1.2
    #releasing2 1.2
    #sleep 0.3
    #releasing3 0.1
    #sleep 1
    #waiting_for_object 1.2 
}
   
coll_gaze_grasping(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4
    waiting_for_object 1.2
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3


    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3 
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object 0.6
    waiting_for_object_gaze
    waiting_for_object_grasping 0.6 #0.2
    sleep 3.3



    #releasing1 1.2
    #releasing2 1.2
    #sleep 0.3
    #releasing3 0.1
    #sleep 1
    #waiting_for_object 1.2
    #sleep 1
    #releasing1 1.2
    #releasing2 1.2
    #sleep 0.3
    #releasing3 0.1
    #sleep 1
    #waiting_for_object 1.2
    #sleep 1
    #releasing1 1.2
    #releasing2 1.2
    #sleep 0.3
    #releasing3 0.1
    #sleep 1
    #waiting_for_object 1.2 
}
coll_gazeathuman_grasping(){
    go_home_helperR 2
    go_home_helperH 2
    go_home_helperT 2
    sleep 4
    waiting_for_object 1.2
    waiting_for_object_grasping 0.5
    sleep 3.3


    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3 
    releasing3 0.1
    gaze_waiting_for_object_athuman 0.6
    waiting_for_object_gaze_athuman
    waiting_for_object_grasping_athuman 0.6   #0.2
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object_athuman 0.6
    waiting_for_object_gaze_athuman
    waiting_for_object_grasping_athuman 0.6
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object_athuman 0.6
    waiting_for_object_gaze_athuman
    waiting_for_object_grasping_athuman 0.6
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object_athuman 0.6
    waiting_for_object_gaze_athuman
    waiting_for_object_grasping_athuman 0.6
    sleep 3.3

    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object_athuman 0.6
    waiting_for_object_gaze_athuman
    waiting_for_object_grasping_athuman 0.6
    sleep 3.3


    gaze_releasing1 0.7
    releasing1_gaze #1.3
    releasing2_obj2 1.3
    releasing3 0.1
    gaze_waiting_for_object_athuman 0.6
    waiting_for_object_gaze_athuman
    waiting_for_object_grasping_athuman 0.6
    sleep 3.3


}


 sequence0_loweffort() {
	go_home
	mostra_muscoli_fast
	sleep 1.5
    	moving_torso_back 1.5 
	go_home_fast
	open_arm_left 1.2
	go_home_fast
	pointing_to_eyes_right 1.8
	go_home
	moving_torso_right 2.0
	moving_torso_left 2.0
	sleep 2.0
	go_home 
	pointing_to_left_forearm 2.5
	sleep 0.5	 
	go_home 
	#presenting_body
    	moving_torso_back 1.8 
	open_arm_left 1.6
	open_arm_right 1.6
	sleep 0.5
	go_home
    }
    sequence0_higheffort() {
	go_home
	mostra_muscoli
	sleep 1.5
	moving_torso_back 2
	go_home
	sleep 1.5 
	open_arm_left 1.5
	go_home
	sleep 1.5 
	pointing_to_eyes_right 2.0
	go_home
	sleep 1.5
	moving_torso_right 3.0
	moving_torso_left 3.0
        sleep 3.0
	go_home
	sleep 1.5  
	pointing_to_left_forearm 3.0
	sleep 3.0	 
	go_home 
	sleep 1.5	 
	#presenting_body
    	moving_torso_back 2.2
	open_arm_left 2
	open_arm_right 2
	sleep 4
	go_home
    }


    test_velocity_slow() {
	go_home
	#A
	mostra_muscoli
	sleep 1.5
	#B
	moving_torso_back 2
	go_home
	sleep 1.5 
	#C
	open_arm_left 2
	go_home
	sleep 1.5 
	#D
	pointing_to_eyes_right 2
	go_home
	#sleep 1.5
	#E
	#moving_torso_right 2.0
	#moving_torso_left 2.0
	#go_home
	#sleep 3  
	#F
	#pointing_to_left_forearm 4.0
	#go_home 
	#sleep 1.5	 
	#G
    	#moving_torso_back 3.2
	#open_arm_left 2
	#open_arm_right 2
	#go_home
	#sleep 1.5
	#H
	#lift_arm_left_infront 4
	#lift_arm_right_infront 4
	#go_home
	#sleep 1.5
	#I
	#pointing_to_right_forearm 4
	#go_home
	#sleep 1.5
	#L
	#pointing_up_arm_right_and_elbow 4
	#go_home
	#sleep 4
	#M
	#rotating_torso_right 4
	#rotating_torso_left 4
	#go_home
	#sleep 1.5
	#N
	stop_faceTracker
	sleep 3
	putting_torso_forward 4
	sleep 3
	start_faceTracker
	go_home
	sleep 10
	#O
	pointing_up_arm_left 4
	go_home
	sleep 1.5

    }
    test_torso_nogaze(){
	go_home
	#A
	mostra_muscoli
	sleep 1.5
	#B
	moving_torso_back 2
	go_home
	sleep 1.5 
	#C
	open_arm_left 2
	go_home
	sleep 1.5 
	stop_faceTracker
	sleep 3
	putting_torso_forward 4
	sleep 3
	start_faceTracker
	go_home
    }

    test_velocity_fast() {
	go_home_fast
	#A
	mostra_muscoli_fast
	#B
	moving_torso_back 1
	go_home_fast
	#C
	open_arm_left 1
	go_home_fast
	#D
	pointing_to_eyes_right 1
	go_home_fast
	#E
	moving_torso_right 1.5
	moving_torso_left 1.5
	go_home_fast
	#F
	sleep 3
	pointing_to_left_forearm 2.0
	go_home_fast 
	#G
    	moving_torso_back 1
	open_arm_left 1
	open_arm_right 1
	go_home_fast
	#H
	lift_arm_left_infront 2
	lift_arm_right_infront 2
	go_home_fast
	#I
	pointing_to_right_forearm 2
	go_home_fast
	sleep 5
	#L
	pointing_up_arm_right_and_elbow 2
	go_home_fast
	sleep 4
	#M
	rotating_torso_right 4
	rotating_torso_left 4
	go_home_fast
	#N
	putting_torso_forward 4
	go_home_fast
	sleep 5
	#O
	pointing_up_arm_left 2
	go_home_fast

    }
    t1_1(){  #sequence1_loweffort() 
	go_home_fast
	#A
	mostra_muscoli_fast
	#D
	pointing_to_eyes_right 1
	go_home_fast
	sleep 2
	#E
	moving_torso_right 1.5
	moving_torso_left 1.5
	go_home_fast
	sleep 2
	#H
	lift_arm_left_infront 2
	lift_arm_right_infront 2
	go_home_fast
	#M
	rotating_torso_right 2
	rotating_torso_left 2
	go_home_fast
	#N
	putting_torso_forward 2
	go_home_fast
    }
    t1_2(){  #sequence1_higheffort()
	go_home
	#A
	mostra_muscoli
	sleep 3
	#D
	pointing_to_eyes_right 2
	go_home
	sleep 1.5
	#E
	moving_torso_right 2.0
	moving_torso_left 2.0
	go_home
	sleep 5  
	#H
	lift_arm_left_infront 4
	lift_arm_right_infront 4
	go_home
	sleep 6
	#M
	rotating_torso_right 4
	rotating_torso_left 4
	go_home
	sleep 3
	#N
	putting_torso_forward 4
	go_home
	sleep 1.5

    }

    t2_1() {  
	go_home_fast
	#E
	moving_torso_right 1.5
	moving_torso_left 1.5
	go_home_fast
	sleep 1
	#A
	mostra_muscoli_fast
	#F
	pointing_to_left_forearm 2
	go_home_fast 
	sleep 3
	#B
	moving_torso_back 1
	go_home_fast
	#C
	open_arm_left 1
	go_home_fast
	sleep 1
	#I
	pointing_to_right_forearm 2
	go_home_fast
    }

    t2_2() {  
	go_home
	#E
	moving_torso_right 2.0
	moving_torso_left 2.0
	go_home
	sleep 3  
	#A
	mostra_muscoli
	sleep 3
	#F
	pointing_to_left_forearm 4.0
	go_home 
	sleep 4
	#B
	moving_torso_back 2
	go_home
	sleep 1.5 
	#C
	open_arm_left 2
	go_home
	sleep 1.5 
	#I
	pointing_to_right_forearm 4
	go_home
	sleep 1.5
    }

    t3_1() {
	go_home_fast
	#H
	lift_arm_left_infront 2
	lift_arm_right_infront 2
	go_home_fast
	#F
	pointing_to_left_forearm 2
	go_home_fast 
	sleep 4
	#E
	moving_torso_right 1.5
	moving_torso_left 1.5
	go_home_fast
	sleep 1
	#L
	pointing_up_arm_right_and_elbow 2
	go_home_fast
	sleep 0.5
	#M
	rotating_torso_right 2
	rotating_torso_left 2
	go_home_fast
	sleep 5
	#G
    	moving_torso_back 1.3
	open_arm_left 1
	open_arm_right 1
	go_home_fast

    }
    t3_2() {
	go_home
	#H
	lift_arm_left_infront 4
	lift_arm_right_infront 4
	go_home
	sleep 3
	#F
	pointing_to_left_forearm 4.0
	go_home 
	sleep 4
	#E
	moving_torso_right 2.0
	moving_torso_left 2.0
	go_home
	sleep 3  
	#L
	pointing_up_arm_right_and_elbow 4
	go_home
	sleep 4
	#M
	rotating_torso_right 4
	rotating_torso_left 4
	go_home
	sleep 7
	#G
    	moving_torso_back 3.2
	open_arm_left 2
	open_arm_right 2
	go_home
	sleep 1.5

    }

    t4_1() {
	go_home_fast
	#L
	pointing_up_arm_right_and_elbow 2
	go_home_fast
	#I
	pointing_to_right_forearm 2
	go_home_fast
	#A
	mostra_muscoli_fast
	sleep 2
	#D
	pointing_to_eyes_right 1
	go_home_fast
	sleep 4.5
	#G
    	moving_torso_back 1.6
	open_arm_left 1
	open_arm_right 1
	go_home_fast
	#O
	pointing_up_arm_left 2
	go_home_fast

    }
    t4_2() {
	go_home
	#L
	pointing_up_arm_right_and_elbow 4
	go_home
	sleep 4
	#I
	pointing_to_right_forearm 4
	go_home
	sleep 4
	#A
	mostra_muscoli
	sleep 4
	#D
	pointing_to_eyes_right 2
	go_home
	sleep 1.5	 
	#G
    	moving_torso_back 3.2
	open_arm_left 2
	open_arm_right 2
	go_home
	sleep 4
	#O
	pointing_up_arm_left 4
	go_home
	sleep 1.5

    }
    t5_1() {
	go_home
	#H
	lift_arm_left_infront 2
	lift_arm_right_infront 2
	go_home_fast
	#E
	moving_torso_right 1.5
	moving_torso_left 1.5
	go_home_fast
	#I
	pointing_to_right_forearm 2
	go_home_fast
	#L
	pointing_up_arm_right_and_elbow 2
	go_home_fast
	#F
	pointing_to_left_forearm 2
	go_home_fast
	#C
	open_arm_left 1
	go_home_fast
    }
    t5_2() {
	go_home
	#H
	lift_arm_left_infront 4
	lift_arm_right_infront 4
	go_home
	sleep 5
	#E
	moving_torso_right 2.0
	moving_torso_left 2.0
	go_home
	sleep 5 
	#I
	pointing_to_right_forearm 4
	go_home
	sleep 4
	#L
	pointing_up_arm_right_and_elbow 4
	go_home
	sleep 5 
	#F
	pointing_to_left_forearm 4.0
	go_home 
	sleep 5	
	#C
	open_arm_left 2
	go_home
	sleep 3 
    }

    t6_1() {
	go_home
	#L
	pointing_up_arm_right_and_elbow 2
	go_home_fast
	#A
	mostra_muscoli_fast
	#D
	pointing_to_eyes_right 1
	go_home_fast
	sleep 3
	#N
	putting_torso_forward 2
	go_home_fast
	#B
	moving_torso_back 1
	go_home_fast
	sleep 2
	#H
	lift_arm_left_infront 2
	lift_arm_right_infront 2
	go_home_fast

    }
    t6_2() {
	go_home
	#L
	pointing_up_arm_right_and_elbow 4
	go_home
	sleep 6
	#A
	mostra_muscoli
	sleep 3
	#D
	pointing_to_eyes_right 2
	go_home
	sleep 1.5
	#N
	putting_torso_forward 4
	go_home
	sleep 3
	#B
	moving_torso_back 2
	go_home
	sleep 1.5 
	#H
	lift_arm_left_infront 4
	lift_arm_right_infront 4
	go_home
	sleep 1.5

    }

    t7_1() {
	go_home_fast
	#B
	moving_torso_back 1
	go_home_fast
	sleep 1.5
	#G
    	moving_torso_back 1.6
	open_arm_left 1
	open_arm_right 1
	go_home_fast
	sleep 1.5
	#M
	rotating_torso_right 2
	rotating_torso_left 2
	go_home_fast
	sleep 2
	#F
	pointing_to_left_forearm 2
	go_home_fast 
	#H
	lift_arm_left_infront 2
	lift_arm_right_infront 2
	go_home_fast
	#L
	pointing_up_arm_right_and_elbow 2
	go_home_fast


    }
    t7_2() {
	go_home
	#B
	moving_torso_back 2
	go_home
	sleep 1.5 
	#G
    	moving_torso_back 3.2
	open_arm_left 2
	open_arm_right 2
	go_home
	sleep 3
	#M
	rotating_torso_right 4
	rotating_torso_left 4
	go_home
	sleep 6
	#F
	pointing_to_left_forearm 4.0
	go_home 
	sleep 5	 	
	#H
	lift_arm_left_infront 4
	lift_arm_right_infront 4
	go_home
	sleep 5
	#L
	pointing_up_arm_right_and_elbow 4
	go_home
	sleep 1.5

    }

    t8_1() {
	#O
	pointing_up_arm_left 2
	go_home_fast
	sleep 2
	#N
	putting_torso_forward 2
	go_home_fast
	#M
	rotating_torso_right 2
	rotating_torso_left 2
	go_home_fast
	sleep 4
	#A
	mostra_muscoli_fast
	#G
    	moving_torso_back 1.6
	open_arm_left 1
	open_arm_right 1
	go_home_fast
	#C
	open_arm_left 1
	go_home_fast

    }
    t8_2() {
	#O
	pointing_up_arm_left 4
	go_home
	sleep 1.5
	go_home
	#N
	putting_torso_forward 4
	go_home
	sleep 1.5
	#M
	rotating_torso_right 4
	rotating_torso_left 4
	go_home
	sleep 9
	#A
	mostra_muscoli
	sleep 1.5
	#G
    	moving_torso_back 3.2
	open_arm_left 2
	open_arm_right 2
	go_home
	sleep 3
	#C
	open_arm_left 2
	go_home
	sleep 1.5 

    }

    l1() {   #robot learns
    	
	writefile $1 l1
	speak "Non ho capito bene, ma?"
	#touch ~/Desktop/"$1" #something.txt
	#echo "$(date +%s.%N) l1" >>~/Desktop/"$p" #something.txt
    }

    l2() {   #robot learns
    	speak "Credo di aver capito, mani?"
    }
    l3() {   #robot learns
    	speak "Ho capito, manico?"
    }
    l4() {   #robot learns
    	speak "Non ho capito bene, d?"
    }
    l4() {   #robot learns
    	speak "Ho capito, dog?"
    }


    fb1(){
    	speak "Hello. We’ve been asked by IIT with teaching each other."
        speak "Let’s practice before we begin the main task. First, a word will now appear on the screen behind me. This is a word I already know."
	speak "Draw it in the air with your hand and I will repeat the word if I can see clearly the letters you are writing."
    }


    fb2(){
    	speak "Great job. Let’s try for a couple more words."
	speak "When you are ready to continue please press the button here."
    }
    fb3(){
    	speak "During the experiment, if I cannot understand the word you have written I will tell you."
	speak "Let’s try now. When the word appears on the screen move your hand up and down."
    }
    fb4(){
    	speak "I didn’t understand it at all"
    }
    fb5(){
    	speak "OK. Now let’s switch. I will now show you some of the dance moves I know."
	speak "See if you can repeat them back to me. Practice as much as you like and then, when you’re ready to continue, please hit the button"
    }


    fbt1(){
	moving_torso_back 2
	go_home
	sleep 1.5 
    }
    fbt1(){
	open_arm_left 2
	go_home  
	sleep 1.5 
    }
    fbt1(){
	pointing_up_arm_left 4
	go_home
	sleep 1.5 
    }



    test(){

	dabbing_left_right
	#go_home
	sleep 1.5 
    }









    timestamp(){
	date +"%s.%N"
    }

    writefile(){   #$1 nomefile, $2 nomefunzione
	touch ~/Desktop/"$1" #nomefile.txt
	echo "$(date +%s.%N) $2" >>~/Desktop/"$1" #something.txt
    }




#######################################################################################
# "MAIN" FUNCTION:                                                                    #
#######################################################################################
echo "********************************************************************************"
echo ""

$1 "$2"

if [[ $# -eq 0 ]] ; then 
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi

