// -*- mode:C++; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

/*
  * Copyright (C)2024  Department of Robotics Brain and Cognitive Sciences - Istituto Italiano di Tecnologia
  * Author:Carlo Mazzola
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
 * @file kInterfaceModule.cpp
 * @brief Implementation of the kInterfaceModule (see header file).
 */

#include "iCub/stateControllerXAEModule.h"

using namespace yarp::os;
using namespace yarp::sig;
using namespace std;
using namespace cv;


///// dictionary

#define COMMAND_VOCAB_HELP               yarp::os::createVocab32('h','e','l','p')
#define COMMAND_VOCAB_QUIT               yarp::os::createVocab32('q','u','i','t')
#define COMMAND_VOCAB_SET                yarp::os::createVocab32('s','e','t')
#define COMMAND_VOCAB_FAILED             yarp::os::createVocab32('f','a','i','l')
#define COMMAND_VOCAB_SUSPEND            yarp::os::createVocab32('s','u','s')
#define COMMAND_VOCAB_RESUME             yarp::os::createVocab32('r','e','s')
#define COMMAND_VOCAB_OK                 yarp::os::createVocab32('o','k')

#include <iostream>
/*
 * Configure method. Receive a previously initialized
 * resource finder object. Use it to configure your module.
 * If you are migrating from the old Module, this is the 
 *  equivalent of the "open" method.
 */
std::mutex sharedMutex;
std::condition_variable condVar;
std::unordered_map<std::string, int> activationModulesDict = {};

bool stateControllerXAEModule::configure(yarp::os::ResourceFinder &rf) {

    if (rf.check("help")) {
        printf("HELP \n");
        printf("====== \n");
        printf(" \n");
        printf("press CTRL-C to stop... \n");
        return true;
    }

    /* Process all parameters from both command-line and .ini file */

    /* get the module name which will form the stem of all module port names */
    if (rf.check("config")) {
        configFile = rf.findFile(rf.find("config").asString().c_str());
        cout << "\nconfigFile is " << configFile << endl;
        if (configFile == "") {
            return false;
        }
    } else {
        configFile.clear();
    }

    moduleName = rf.check("name",
                          Value("/stateControllerXAE"),
                          "module name (string)").asString();
    /*
    * before continuing, set the module name before getting any other parameters, 
    * specifically the port names which are dependent on the module name
    */
    setName(moduleName.c_str());

    /*
    * get the robot name which will form the stem of the robot ports names
    * and append the specific part and device required
    */
    robotName = rf.check("robot",
                         Value("icub"),
                         "Robot name (String)").asString();
    cout << "\nrobotName is " << robotName << endl;

//    cout << modules_bottle->size() << endl;
//    for (int i = 0; i <= modules_bottle->size(); ++i) {
//        modules.push_back(modules_bottle->get(i).asString());
//        modules.push_back("a");
//    }
//
//    cout << "List elements: ";
//    for (std::string str : modules) {
//        cout << str << " ";
//    }
//    cout << endl;

    /*
    * attach a port of the same name as the module (prefixed with a /) to the module
    * so that messages received from the port are redirected to the respond method
    */
    handlerPortName = "";
    handlerPortName += getName();         // use getName() rather than a literal 

    if (!handlerPort.open(handlerPortName.c_str())) {
        cout << getName() << ": Unable to open port " << handlerPortName << endl;
        return false;
    }

    attach(handlerPort);                  // attach to port

    yInfo("Configuration of the RF module correctly ended");

    /* create the thread and pass pointers to the module parameters */

    pThread = new stateControllerXAEThread(robotName, rf);
    pThread->setName(getName().c_str());
    vThread = new visualizerThread(robotName, rf);
    vThread->setName(getName().c_str());

    /* now start the thread to do the work */
    pThread->start(); // this calls threadInit() and it if returns true, it then calls run()
    vThread->start();

    return true;       // let the RFModule know everything went well
    // so that it will then run the module
}

bool stateControllerXAEModule::interruptModule() {
    handlerPort.interrupt();
    return true;
}

bool stateControllerXAEModule::close() {
    handlerPort.close();
    /* stop the thread */
    printf("stopping the thread \n");
    vThread->stop();
    pThread->stop();
    return true;
}

bool stateControllerXAEModule::respond(const Bottle &command, Bottle &reply) {
    bool ok = false;
    bool rec = false; // is the command recognized?

    string helpMessage = string(getName().c_str()) +
                         " commands are: " +
                         "help " +
                         "set "
                         "quit ";

    reply.clear();

    switch (command.get(0).asVocab32()) {
        case COMMAND_VOCAB_HELP:
            rec = true;
            {
                //reply.addVocab32(Vocab32::encode("many"));
                reply.addString(helpMessage.c_str());
                ok = true;
            }
            break;

        case COMMAND_VOCAB_QUIT:
            rec = true;
            {
                reply.addString("quitting");
                ok = true;

            }
            return false;
            break;

        case COMMAND_VOCAB_SET:
            rec = true;
            {
                if (command.get(1).asInt32() == 1) {
                    ok = true;
                    pThread->currentState = states::WAITING;
                }
                else if (command.get(1).asInt32() == 2) {
                    ok = true;
                    pThread->currentState = states::CLASSIFYING;
                }
                else {
                    reply.addString("you can set the following states");
                    reply.addString("1->WAITING");
                    reply.addString("2->CLASSIFYING");
                    reply.addString("otherwise:");
                    reply.addString(helpMessage.c_str());
                }
                ok = true;
            }
            break;

        case COMMAND_VOCAB_SUSPEND:
            rec = true;
            {
                reply.addString("suspending processing");
                vThread->resume();
                pThread->suspend();
                ok = true;
            }
            break;

        case COMMAND_VOCAB_RESUME:
            rec = true;
            {
                reply.addString("resuming processing");
                vThread->resume();
                pThread->resume();
                ok = true;
            }
            break;

        default:
            rec = false;
            ok = false;
    }

    respondLock.post();

    if (!rec) {
        ok = RFModule::respond(command, reply);
    }

    if (!ok) {
        reply.clear();
        reply.addVocab32(COMMAND_VOCAB_FAILED);
        reply.addString(helpMessage.c_str());
    } else
        reply.addVocab32(COMMAND_VOCAB_OK);

    return true;
}

/* Called periodically every getPeriod() seconds */
bool stateControllerXAEModule::updateModule() {
    return true;
}

double stateControllerXAEModule::getPeriod() {
    /* module periodicity (seconds), called implicitly by myModule */
    return 1;
}


