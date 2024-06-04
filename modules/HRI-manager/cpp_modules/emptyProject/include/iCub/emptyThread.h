// -*- mode:C++; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

/*
  * Copyright (C)2022  Department of Robotics Brain and Cognitive Sciences - Istituto Italiano di Tecnologia
  * Author: Carlo Mazzola
  * email: carlo.mazzola@iit.it
  * Permission is granted to copy, distribute, and/or modify this program
  * under the terms of the GNU General Public License, version 2 or any
  * later version published by the Free Software Foundation.
  *
  * A copy of the license can be found at
  * http://www.robotcub.org/icub/license/gpl.txt
  *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
  * Public License for more details
*/


/**
 * @file stateControllerXAE.h
 * @brief Definition of a thread that receives input from keyboard and outputs it as a string on a port
 */


#ifndef _STATECONTROLLERXAE_THREAD_H_
#define _STATECONTROLLERXAE_THREAD_H_

#include <yarp/sig/all.h>
#include <yarp/os/all.h>
#include <yarp/dev/all.h>
#include <yarp/os/PeriodicThread.h>
#include <iostream>
#include <fstream>
#include <time.h>
#include <stdio.h>
//#include <opencv/cv.h>  // if yarp is not installed with robotology-superbuild
#include <yarp/cv/Cv.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <thread>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <map>
#include <unordered_map>
#include <list>

enum states {
    DEFAULT = 0,
    WAITING = 1,
    CLASSIFYING = 2,
    };



class stateControllerXAEThread: public yarp::os::PeriodicThread {
private:

    /****************** ATTRIBUTES ******************/
    bool idle;                      // flag that interrupts the processing
    int c;                          // character read from keyboard

    std::string robot;              // name of the robot
    yarp::os::ResourceFinder rf;

    bool sound;
    bool speaker;
    bool addressee;
    bool speakerLocalized;
    bool listen;
    bool robotAddressed;

    int previousState;
    int speakerBin;
    int addresseeBin;
    int currentBin;
    int audioInstance;
    float confidenceClassification;
    float confidenceLocalization;

    float speakerAngle;
    float addresseeAngle;

    std::string name;    // rootname of all the ports opened by this thread
    std::string action;
    std::string command;
    std::string addresseeDirection;
    std::string commandAction;
    std::string finalEstimationInfo;
    std::string localizationStatus;
    std::string speakerSentence;
    std::string answer;

    std::unordered_map<int, std::string> binDictZone;
    std::unordered_map<std::string, int> addresseeDictBin;
    std::unordered_map<std::string, std::string> directionDict;
    ///std::unordered_map<std::string, int> activationModulesDict;

    std::vector<int> zones;

    yarp::os::Bottle cmd;
    yarp::os::Bottle message;
    yarp::os::Bottle modules_bottle;

    yarp::os::Bottle* inputInfoBottle;
    //yarp::os::Bottle* soundInfoBottle;
    //yarp::os::Bottle* speakerInfoBottle;

    /* RpcClient */
    yarp::os::RpcClient clientRPCAction;
    yarp::os::RpcClient clientRPCAddresseeClassifier;
    yarp::os::RpcClient clientRPCSpatialMemory;

    /* Buffered Input Ports */
    yarp::os::BufferedPort<yarp::sig::ImageOf<yarp::sig::PixelRgb> > inputImagePort;  // input port that takes as input image from robot's camera
    yarp::os::BufferedPort<yarp::os::Bottle> inputAddresseePort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputSoundPort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputSpeakerPort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputMemoryPort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputObjectPort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputTextPort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputLLMPort;
    yarp::os::BufferedPort<yarp::os::Bottle> inputAcapelaBookmarkPort;

    /* Buffered Output Ports */
    yarp::os::BufferedPort<yarp::os::Bottle> outputActionPort;     // output port , result of the processing
    yarp::os::BufferedPort<yarp::os::Bottle> outputMemoryPort;
    ///yarp::os::BufferedPort<yarp::os::Bottle> outputVisualizerPort;
    yarp::os::BufferedPort<yarp::os::Bottle> outputLLMPort;

    bool sendRpcCommand(yarp::os::RpcClient &, const yarp::os::Bottle &); //function to send command for interactioninterface
    void receiveSpeechInfo();
    void processSpeechInfo();
    void receiveAddresseeInfo();
    void processAddresseeInfo();
    void receiveSentence();
    void receiveAcapelaBookmark();
    void check_people_in_direction();
    void sendMessageAddressee(std::string);
    void sendMessageAction(std::string, std::string, int);
    void sendExpressionAction(std::string, std::string, std::string, std::string);
    void sendLLMInfo();
    void updateVisualizerInfo();
    void setRoleInMemory(std::string, std::string);
    void getZonesFromMemory(std::string);
    bool isAddresseeThere(std::string);
    void setiCubExpressions();
    //void manageLLManswer(bool);
    bool readObjectRecognition();
    //bool getFromMemory(std::string);

public:

    states currentState;

    /**
    * constructor default
    */
    stateControllerXAEThread();

    /**
    * constructor 
    * @param robotname name of the robot
    */
    stateControllerXAEThread(std::string robotname, yarp::os::ResourceFinder &_rf);

    /**
     * destructor
     */
    ~stateControllerXAEThread();

    /**
    *  initialises the thread
    */
    bool threadInit();

    /**
    *  correctly releases the thread
    */
    //void threadRelease();

    /**
    *  active part of the thread
    */
    void run();

    /**
    *  on stopping of the thread
    */
    void onStop();

    /**
    * function that sets the rootname of all the ports that are going to be created by the thread
    * @param str rootnma
    */
    void setName(std::string str);

    /**
    * function that returns the original root name and appends another string iff passed as parameter
    * @param p pointer to the string that has to be added
    * @return rootname 
    */
    std::string getName(const char *p);

    /**
     * @brief suspend the processing of the module
     */
    void suspend();

    /**
     * @brief function of main processing in the thread
     */
    void resume();

};


#endif  //_stateControllerXAE_THREAD_H_

//----- end-of-file --- ( next line intentionally left blank ) ------------------

