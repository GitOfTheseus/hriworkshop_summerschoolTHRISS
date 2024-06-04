# iCub Interaction Demos
Set of validated and tested Behaviors for iCub, useful during Demos.
Each beahvior is defined inside an executable (`.sh`) script, composed starting from atomic basic behaviors.

The `interactionInterface` module allows to load executable scripts and call the defined methods through RPC.

## Installation
Clone this repo in `/usr/local/src/robot/congnitiveInteraction` (here is where we should put our source code).
Then do: 
```bash 
cd icub-iteraction-demos
mkdir build
cd build
ccmake ../ -> c -> c -> g
# Review and merge any untracked changes
make install
```
This will install the app in `../ICUBcontrib/applications` and an associated template in `../ICUBcontrib/templates`. <br />
**The `.sh` files containing iCub's beahviors are installed in `../ICUBcontrib/context/icubDemos`**

### What if there are untracked fine tuning changes?
It's not unusual to find untracked changes in the installed files. A lot of times we modify them and forget to upload the changes on Gitlab.

If that's so a **Meld** view will open when you hit the *configure* on `ccmmake ../` asking you to review and merge the changes on the installed files. Please review any green bar on the right panel (the installed file) and hit the black arrow to report it on the left panel (the source file).

Once you completed your installtion, please upload the changes with
```bash
git add --all
git commmit -m "merging untracked fine tuning"
git push
```


## Start the Module
From `yarpmanager` open **ICub Interaction Demos** and run the `interactionInterface` application along with the three `ctpService` defined for left/right arms and torso.

interactionInterface accepts two arguments:
- `--config` = the .sh file you want to use (default is _icub_demos.sh_) 
- `--context` = the context folder where to search for the .sh script (default is _icubDemos_) 

Alternatively you can load the .sh file while interactionInterface is running by writing on its port:
```sh
yarp rpc /interactionInterface
load file <aboslute/path/of/my_script.sh> #YOU MUST USE THE ABSOLUTE PATH!
```
## Execute beahviors

Depending on the specific Demo that you want to show, You will need other applications such as:
* *Face Duo Expressions*
* *robotStartup (robotInterface and iKinGazeCtrl)*
* *Acapela Speak*


**You can execute behaviors by writing on the `/interactionInterface` port**

```sh
yarp rpc /interactionInterface
exe <beaviour> #execute the defined behavior (e.g. exe saluta)
```

Notice that the script exploits another script called `icub_basics.sh` that defines all the basic and atomic behaviors that icub can perform. A demo is defined as a sequential combination of those basic behaviors.

## Fine tuning your Demo

As soon as you run your demo, you will probably notice some inconsistency, expecially if you developed it on the simulator.
Don't worry, you can fine tune the correct positions with the `yarpmotorgui` and apply the changes on your `demo.sh` in `../ICUBcontrib/context/icubDemos` while the interactionInterface is running.

**If you make any fine tunning, please remember to report the changes on the source files and push them on Gitlab.**

## Add new Demos
Feel free to add new **validated and tested** demos to the `icub_demos.sh` script. _**Don't forget to commit on gitlab the changes.**_

Just pay a major attention to:
*  Define safe movements for iCub trying to use `icub_basics.sh` methods as much as possible.
*  Test, test, test and test them in order to be really sure of their safety.
*  Notice your advisor and team of the new demo.

## Use demo behaviors for your experiments
You can exploit these behaviors for your personal experiments, just be sure to have a dedicated `context` folder containing your .sh file. 
Eventually you can make your .sh files inherit behaviourS from the demo files (see how in the next section).

## How to create new behaviors

If you want to create a one-shot demo for a specific event or for an experiment. One example of this scenario is the `alessia_demo.sh`.

To do that, please respect the same structure of `icub_demos.sh`.
Moreover you must ensure that the script is executable.

```sh
touch my_script.sh
gedit my_script.sh #write the script, follow the template
chmod +x my_script.sh
```

#### Script Template
```sh
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
source /usr/local/src/robot/robotology-superbuild/build/install/share/ICUBcontrib/contexts/icubDemos/icub_basics.sh

#######################################################################################
# "MAIN" DEMOS:                                                                       #
#######################################################################################

# PUT HERE YOUR DEMO #
testCiao(){
    speak "ciao"
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

```
