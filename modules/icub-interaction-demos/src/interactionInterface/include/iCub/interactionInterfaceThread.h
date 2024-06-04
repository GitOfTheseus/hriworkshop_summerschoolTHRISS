//
/*
  * Copyright (C)2017  Department of Robotics Brain and Cognitive Sciences - Istituto Italiano di Tecnologia
  * Author:Francesco Rea & Gonzalez Jonas
  * email: francesco.rea@iit.it
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
//

/**
 * @file interactionInterfaceThread..h
 * @brief Definition of a thread that receives an action and execute it on the specified script.
 */

#ifndef INTERFACESHELL_interactionInterfaceThread_H
#define INTERFACESHELL_interactionInterfaceThread_H

#include <yarp/sig/all.h>
#include <yarp/os/BufferedPort.h>
#include <yarp/os/RFModule.h>
#include <yarp/os/Network.h>
#include <yarp/os/Thread.h>
#include <yarp/os/Time.h>
#include <yarp/dev/all.h>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/core/types_c.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <iterator>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/types.h>


using namespace std;

class interactionInterfaceThread : public yarp::os::Thread {
private:
    std::string robot;              // name of the robot
    std::string name;               // rootname of all the ports opened by this thread
    std::string m_scriptName;
    std::string audioPlayer;
    std::string inputTextName;
    std::string outputImageName;

    yarp::os::BufferedPort<yarp::sig::ImageOf<yarp::sig::PixelBgr> > outputImageTextPort;     //output port for the image with text
    yarp::os::BufferedPort<yarp::os::Bottle> inputTextPort;    //input port for receiving the text to display

    IplImage* outputImageIpl;

    const int width = 1000;
    const int height = 600;

    const int  READ =  0;
    const int  WRITE = 1;


public:
    /**
    * constructor default
    */
    interactionInterfaceThread();

    /**
    * constructor
    * @param _robot name of the robot
    * @param _scriptName name of the script to use to execute actions
    */
    interactionInterfaceThread(std::string scriptName, std::string _robot, yarp::os::ResourceFinder rf);

    /**
    * constructor
    * @param _robot name of the robot
    */
    interactionInterfaceThread(std::string _robot, yarp::os::ResourceFinder rf);

    /**
     * destructor
     */
    ~interactionInterfaceThread();

    /**
    * function that sets the rootname of all the ports that are going to be created by the thread
    * @param str rootname
    */
    void setName(std::string str);


    /**
    * function that returns the original root name and appends another string iff passed as parameter
    * @param p pointer to the string that has to be added
    * @return rootname
    */
    std::string getName(const char* p);


    /**
    *  initialises the thread
    */
    bool threadInit() override;

    /**
    *  correctly releases the thread
    */
    void threadRelease();

    /**
    *  active part of the thread
    */
    void run() override;

    void onStop();

    std::vector <std::string> exec(std::string cmd);
    std::vector <std::string> exec(std::string cmd, yarp::os::Bottle params);


    bool playAudioFile(std::string cmd, int &PIPEPID);
    map<int, FILE*> filePidPairs;
    bool stopAllAudio();
    bool stopAudio(int pipePid);


    std::vector<std::string> formatTextToDisplay(std::string inputText, cv::Size textSize, cv::Mat displayImage);


    cv::Mat writeTextToImage(std::string t_inputText);

    bool loadFile(std::string t_file);

    // helper functions
    int pclose2(FILE * fp, pid_t pid);
    FILE* popen2(string command, string type, int & pid);

};


#endif //INTERFACESHELL_interactionInterfaceThread_H
