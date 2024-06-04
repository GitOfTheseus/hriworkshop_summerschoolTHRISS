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
 * @file StateControllerXAEThread.cpp
 * @brief Implementation of the keyboard thread (see kInterfaceThread.h).
 */

#include <iCub/visualizerThread.h>
#include <iCub/stateControllerXAEThread.h>
#include <iCub/stateControllerXAEModule.h>
#include <cstring>
#include <iostream>
#include <map>
#include <chrono>
#include <thread>
#include <vector>
#include <algorithm>

using namespace yarp::dev;
using namespace yarp::os;
using namespace yarp::sig;
using namespace std;
using namespace cv;

#define THPERIOD 0.01
#include <list>


stateControllerXAEThread::stateControllerXAEThread() : PeriodicThread(THPERIOD) {
    robot = "icub";
    idle = false;
}

stateControllerXAEThread::stateControllerXAEThread(string _robot, yarp::os::ResourceFinder &_rf) : PeriodicThread(
        THPERIOD) {
    robot = _robot;
    rf = _rf;
    idle = false;
}

stateControllerXAEThread::~stateControllerXAEThread() {
    // do nothing
    //clientCartCtrlTorso.close();
}

bool stateControllerXAEThread::threadInit() {

    yInfo("\nInitialization of the thread");

    currentState = DEFAULT;
    previousState = DEFAULT;
    addresseeDirection = "";
    finalEstimationInfo = "";
    localizationStatus = "";
    speakerSentence = "";
    answer = "";
    sound = false;
    speaker = false;
    addressee = false;
    speakerLocalized = false;
    listen = true;
    robotAddressed = false;

    confidenceClassification = 0;
    confidenceLocalization = 0;
    speakerBin = 2;
    addresseeBin = 2;
    currentBin = 2;

    audioInstance = 1;

    speakerAngle = 0;

    inputInfoBottle = NULL;

//    binDictZone = {
//            {0, "far_left"},
//            {1, "left"},
//            {2, "center"},
//            {3, "right"},
//            {4, "far_right"}
//    };

    binDictZone = {
            {0, "far_left"},
            {2, "center"},
            {4, "far_right"}
    };

    addresseeDictBin = {
            {"left", 0},
            {"right", 4}
    };

    directionDict = {
            {"left", "leftward"},
            {"right", "rightward"}
    };

    ///activationModulesDict = {};

    modules_bottle = rf.findGroup("Modules");
    cout << "modules size " << modules_bottle.size() << endl;
    cout << "all modules " << modules_bottle.toString() << endl;
    for (int i=1; i<modules_bottle.size(); i++) {
        string module = modules_bottle.get(i).asList()->get(0).asString();
        activationModulesDict[module] = modules_bottle.get(i).asList()->get(1).asInt8();
        cout << module << " " << activationModulesDict[module] << endl;
    }

    /************************************************ OPEN PORTS ************************************************/

    //interaction interface port
    clientRPCAction.setRpcMode(true);
    if (!clientRPCAction.open(getName("/action:rpc").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // addressee classifier port
    clientRPCAddresseeClassifier.setRpcMode(true);
    if (!clientRPCAddresseeClassifier.open(getName("/message:rpc").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // spatial memory rpc port
    clientRPCSpatialMemory.setRpcMode(true);
    if (!clientRPCSpatialMemory.open(getName("/spatialMemory:rpc").c_str())) {
        yError("Unable to open %s port ",getName("/spatialMemory:rpc").c_str());
        return false;
    }

    // input port to receive info
    if (!inputAddresseePort.open(getName("/addressee:i").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // input port to receive info
    if (!inputSoundPort.open(getName("/audio:i").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // input port to receive info
    if (!inputSpeakerPort.open(getName("/speaker:i").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // input port to receive info from memory
    if (!inputMemoryPort.open(getName("/memory:i").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // input port to receive info from memory
    if (!inputObjectPort.open(getName("/objects:i").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // input port to receive info from speech2text
    if (!inputTextPort.open(getName("/text:i").c_str())) {
        yError("unable to open port to send interaction command ");
        return false;
    }

    // input port to the send info to LLM
    if (!inputLLMPort.open(getName("/LLM:i").c_str())) {
        yError("unable to open port to send info to the wizard ");
        return false;
    }

    // input port to the send info to LLM
    if (!inputAcapelaBookmarkPort.open(getName("/bookmark:i").c_str())) {
        yError("unable to open port to send info to the wizard ");
        return false;
    }

    // output port to the send info
    if (!outputActionPort.open(getName("/action:o").c_str())) {
        yError("unable to open port to send info to the wizard ");
        return false;
    }

    // output port to the send info
    if (!outputMemoryPort.open(getName("/memory:o").c_str())) {
        yError("unable to open port to send info to the memory ");
        return false;
    }

//    // output port to the send info
//    if (!outputVisualizerPort.open(getName("/visualizer:o").c_str())) {
//        yError("unable to open port to send info to the visualizer ");
//        return false;
//    }

    // output port to the send info to LLM
    if (!outputLLMPort.open(getName("/LLM:o").c_str())) {
        yError("unable to open port to send info to the llm ");
        return false;
    }



    yInfo("Initialization of the processing thread correctly ended");

    return true;

}

void stateControllerXAEThread::suspend() {
    yDebug("suspending");
}

void stateControllerXAEThread::resume() {
    yDebug("resuming");
}

void stateControllerXAEThread::setName(string str) {
    this->name = str;
}

std::string stateControllerXAEThread::getName(const char *p) {
    string str(name);
    str.append(p);
    return str;
}

void stateControllerXAEThread::onStop() {

    yInfo("\n closing the ports");

    clientRPCAction.interrupt();
    clientRPCAction.close();
    clientRPCAddresseeClassifier.interrupt();
    clientRPCAddresseeClassifier.close();
    clientRPCSpatialMemory.interrupt();
    clientRPCSpatialMemory.close();

    inputAddresseePort.interrupt();
    inputAddresseePort.close();
    inputSoundPort.interrupt();
    inputSoundPort.close();
    inputSpeakerPort.interrupt();
    inputSpeakerPort.close();
    inputMemoryPort.interrupt();
    inputMemoryPort.close();
    inputObjectPort.interrupt();
    inputObjectPort.close();
    inputTextPort.interrupt();
    inputTextPort.close();
    inputLLMPort.interrupt();
    inputLLMPort.close();
    inputAcapelaBookmarkPort.interrupt();
    inputAcapelaBookmarkPort.close();

    outputActionPort.interrupt();
    outputActionPort.close();
    outputMemoryPort.interrupt();
    outputMemoryPort.close();
    ///outputVisualizerPort.interrupt();
    ///outputVisualizerPort.close();
    outputLLMPort.interrupt();
    outputLLMPort.close();

    yInfo("\n ports closed");
}

bool stateControllerXAEThread::sendRpcCommand(yarp::os::RpcClient &RpcPort, const yarp::os::Bottle &cmd) {

    if (RpcPort.getOutputCount()) {
        //cout << " cmd is " << cmd.get(0).asString() << " " << cmd.get(1).asString() << endl;
        yarp::os::Bottle response;
        RpcPort.write(cmd, response);
        return response.toString().find("ok") != std::string::npos;
    }
    return false;
}

void stateControllerXAEThread::getZonesFromMemory(std::string role){
    zones.clear();
    //std::vector<int> zones(0); ###
    yarp::os::Bottle msg;
    msg.addString("get");
    msg.addString("zone");
    msg.addString(role);
    if (clientRPCSpatialMemory.getOutputCount()) {
        activationModulesDict["spatialMemory"] = 1;
        yarp::os::Bottle response;
        clientRPCSpatialMemory.write(msg, response);
        if (response.get(0).asBool()) {
            //cout << " there is at least one " << role << endl;
            if (yarp::os::Bottle *bZones = response.get(1).asList()){
                //std::vector<int> zones(size); ###e
                for (int i=0; i<bZones->size(); i++) {
                    zones.push_back(bZones->get(i).asInt64());
                    //zones[i]=bZones->get(i).asInt64(); ###
                }
            }
        }
        //cout << "receiving response from MEMORY " << response.toString() << endl;

    } else {
        activationModulesDict["spatialMemory"] = 0;
    }

    // return std::move(zones); ###
    return;
}

void stateControllerXAEThread::setRoleInMemory(std::string role, std::string zone){

    message.clear();
    message.addString("set");
    message.addString(role);
    message.addString(zone);
    //cout << "sending message to MEMORY " << message.toString() << endl;
    sendRpcCommand(clientRPCSpatialMemory, message);

}

void stateControllerXAEThread::sendMessageAddressee(std::string command) {

    message.clear();
    message.addString(command);

    sendRpcCommand(clientRPCAddresseeClassifier, message);
}

void stateControllerXAEThread::sendMessageAction(std::string command, std::string info, int new_currentBin=-1) {

    yarp::os::Bottle msg;
    msg.clear();
    msg.addString(command);
    if (command == "look") {
        currentBin = new_currentBin;
        activationModulesDict["move"] = 1;
        msg.addString(info);
        cout << "--> ACTION " << msg.toString() << endl;
    } else if (command == "tell") {
        //listen = false;
        activationModulesDict["speak"] = 1;
        activationModulesDict["languageReasoning"] = 1;
        msg.addString(info);
        cout << "--> ACTION " << msg.toString() << endl;
    } else {
        msg.addString("");
    }
    cout << "currentBin is " << currentBin;
    outputActionPort.prepare() = msg;
    outputActionPort.write();

}

void stateControllerXAEThread::sendExpressionAction(std::string command, std::string action, std::string what, std::string how) {

    yarp::os::Bottle msg;
    msg.clear();
    msg.addString(command);
    msg.addString(action);
    msg.addString(what);
    msg.addString(how);

    outputActionPort.prepare() = msg;
    outputActionPort.write();
    yarp::os::Time::delay(0.15);

}

bool stateControllerXAEThread::readObjectRecognition() {

    if (inputObjectPort.getInputCount()) {
        yarp::os::Bottle *objectInfoBottle;
        objectInfoBottle = inputObjectPort.read(false);
        if (objectInfoBottle != NULL) {
            return true;
        }
    }
    return false;
}

bool stateControllerXAEThread::isAddresseeThere(std::string direction) {
    // check if there is anybody in a specific direction to identify a possible addressee
    //cout << "is Anybody " << direction << "?" << endl;
    getZonesFromMemory("person");

    if (empty(zones)) {
        //cout << "there is nobody there" << endl;
        return false;
    } else {
        if (direction == "rightward") {
            if (*std::max_element(zones.begin(), zones.end()) >= speakerBin) {
                addresseeBin = *std::max_element(zones.begin(), zones.end());
                //cout << "A addresseeBin is " << addresseeBin << endl;
                return true;
            } else {
                //cout << "B addresseeBin is " << addresseeBin << endl;
                return false;
            }
        } else if (direction == "leftward") {
            if (*std::min_element(zones.begin(), zones.end()) <= speakerBin) {
                addresseeBin = *std::min_element(zones.begin(), zones.end());
                //cout << "C addresseeBin is " << addresseeBin << endl;
                return true;
            } else {
                //cout << "D addresseeBin is " << addresseeBin << endl;
                return false;
            }
        }
    }
    //cout << "E addresseeBin is " << addresseeBin << endl;
    return false;

}

void stateControllerXAEThread::receiveAddresseeInfo() {
    
    if (inputAddresseePort.getInputCount()) {
        inputInfoBottle = inputAddresseePort.read(false);
        if (inputInfoBottle != NULL) {
            addresseeDirection = inputInfoBottle->get(0).asString();
            confidenceClassification = inputInfoBottle->get(1).asFloat64();
            finalEstimationInfo = inputInfoBottle->get(2).asString();
            addressee = true;
            cout << addresseeDirection << " " << finalEstimationInfo << endl;
            setiCubExpressions();

        } else {
            addresseeDirection = "";
            confidenceClassification = 0;
        }
    }
    return;
}

void stateControllerXAEThread::processAddresseeInfo() {

    //sendMessageAction("tell", addresseeDirection);
    //yarp::os::Time::delay(0.5);

    if (not empty(addresseeDirection)) {
        // IF ANY CLASSIFICATION IS RECEIVED
        receiveSentence();
        sendMessageAction("tell", " \\mrk=0\\ " + finalEstimationInfo +  " \\mrk=1\\ .");
        yarp::os::Time::delay(0.1);

        if (addresseeDirection == "robot") {
            //listen = false;
            sendLLMInfo();

            //sendExpressionAction("exp", "set", "all", "hap");
            //sendExpressionAction("exp", "set", "col", "red");
            //manageLLManswer(false);
        } else { // check for the addressee

            sendExpressionAction("exp", "set", "col", "white");

            // IF ROBOT REMEMBERS SOMEBODY IN THAT DIRECTION
            if (isAddresseeThere(directionDict[addresseeDirection])) {     // check from memory if anybody is there and if so save it as addressee
                yDebug("ROBOT REMEMBERS SOMEBODY IN THAT DIRECTION");
                sendMessageAction("look", binDictZone[addresseeBin], addresseeBin);
                yarp::os::Time::delay(1);
                activationModulesDict["move"] = 0;
                // CHECK THERE IS STILL SOMEBODY THERE
                if (readObjectRecognition()) {
                    setRoleInMemory("addressee", binDictZone[addresseeBin]);
                    robotAddressed = false;
                } else {
                    robotAddressed = true;
                }

            // IF ROBOT DOESN'T REMEMBER ANYBODY IN THAT DIRECTION
            } else {
                yDebug("ROBOT DOESN'T REMEMBER ANYBODY IN THAT DIRECTION");
                check_people_in_direction();  // check people in addressee's direction and put them into spatial memory if present

                if (isAddresseeThere(directionDict[addresseeDirection])) {        // IF SOMEBODY WAS FOUND IN THAT DIRECTION
                    yDebug("SOMEBODY WAS FOUND IN THAT DIRECTION");
                    setRoleInMemory("addressee", binDictZone[addresseeBin]);
                    sendMessageAction("look", binDictZone[addresseeBin], addresseeBin);
                    yarp::os::Time::delay(1);
                    activationModulesDict["move"] = 0;
                    robotAddressed = false;
                } else { // IF NOBODY WAS FOUND IN THAT DIRECTION
                    robotAddressed = true;
                    yDebug("NOBODY WAS FOUND IN THAT DIRECTION");
                }

                if (robotAddressed) {

                sendMessageAction("look", binDictZone[speakerBin], speakerBin);
                yarp::os::Time::delay(1);
                activationModulesDict["move"] = 0;
                sendExpressionAction("exp", "set", "all", "neu");
                //
                //listen = false;
                sendMessageAction("tell", " \\mrk=0\\ But Since I haven't seen nobody to my " + addresseeDirection + " I guess you "
                                                                                                                     "were talking to me \\mrk=1\\ .");
                yarp::os::Time::delay(0.1);
                sendExpressionAction("exp", "set", "col", "red");
                sendExpressionAction("exp", "set", "all", "hap");
                //manageLLManswer(false);
                addresseeDirection = "robot";

                }

            }

            sendLLMInfo();

        }
    }

}

void stateControllerXAEThread::receiveSentence() {

    if (inputTextPort.getInputCount()) {
        yarp::os::Bottle *sentenceBottle;
        sentenceBottle = inputTextPort.read(false);
        if (sentenceBottle != NULL) {
            speakerSentence = sentenceBottle->get(0).asString();
            cout << "SENTENCE IS :" << sentenceBottle->toString() << endl;
        }
    }

}

void stateControllerXAEThread::receiveAcapelaBookmark() {

    if (inputAcapelaBookmarkPort.getInputCount()) {
        yarp::os::Bottle *bookmarkBottle;
        bookmarkBottle = inputAcapelaBookmarkPort.read(false);
        if (bookmarkBottle != NULL) {
            listen = bookmarkBottle->get(0).asBool();
            cout << "A NEW listen is RECEIVED !!!!!!!!!!!!!!!!" << listen << endl;
            if (listen) {
                sendExpressionAction("exp", "set", "col", "white");
            } else {
                sendExpressionAction("exp", "set", "col", "green");
            }

        }
    }

}

//void stateControllerXAEThread:: manageLLManswer(bool shouldwait) {
//
//    cout << "managing LLM answer" << endl;
//
//    answer = "";
//    if (inputLLMPort.getInputCount()) {
//        yarp::os::Bottle *answerBottle;
//
//        answerBottle = inputLLMPort.read(shouldwait);
//        if (answerBottle != NULL) {
//            answer = answerBottle->get(0).asString();
//            //cout << "!!!!!             llm answered: " << answerBottle->toString() << endl;
//        }
//    } else {
//        listen = true;
//    }
//    sendMessageAction("tell", answer);
//    yarp::os::Time::delay(1);
//
//}

void stateControllerXAEThread::sendLLMInfo(){

    activationModulesDict["languageReasoning"] = 1;
    if (outputLLMPort.getOutputCount()) {
        yarp::os::Bottle LLMBottle;
        LLMBottle.clear();
        LLMBottle.addString(speakerSentence);
        LLMBottle.addString(addresseeDirection);
        cout << "sending to LLM " << LLMBottle.toString() << endl;
        outputLLMPort.prepare() = LLMBottle;
        outputLLMPort.write();
    }

}

void stateControllerXAEThread::updateVisualizerInfo(){

    if (inputAddresseePort.getInputCount()) {
        activationModulesDict["camera"] = 1;
        activationModulesDict["visualProcessing"] = 1;
    } else {
        activationModulesDict["camera"] = 0;
        activationModulesDict["visualProcessing"] = 0;
    }

    if (inputSoundPort.getInputCount()) {
        activationModulesDict["mic"] = 1;
    } else {
        activationModulesDict["mic"] = 0;
    }

//    if (outputVisualizerPort.getOutputCount()) {
//
//        yarp::os::Bottle visualizerBottle_ext;
//        visualizerBottle_ext.clear();
//        for (const auto& pair : activationModulesDict) {
//            Bottle &visualizerBottle_int = visualizerBottle_ext.addList();
//            visualizerBottle_int.addString(pair.first);
//            visualizerBottle_int.addInt8(pair.second);
//        }
//        outputVisualizerPort.prepare() = visualizerBottle_ext;
//        outputVisualizerPort.write();
//    }

}

void stateControllerXAEThread::receiveSpeechInfo() {

    receiveAcapelaBookmark();

    if (listen) {                              // IF THE ROBOT IS NOT TALKING

        activationModulesDict["speak"] = 0;
        activationModulesDict["languageReasoning"] = 0;

        if (inputSoundPort.getInputCount()) {
            activationModulesDict["mic"] = 1;
            yarp::os::Bottle* soundInfoBottle;
            soundInfoBottle = inputSoundPort.read(false);
            if (soundInfoBottle != NULL) {
                sound = soundInfoBottle->get(0).asBool();
                //cout << sound << " " << localizationStatus << endl;
            }
        }

        if (inputSpeakerPort.getInputCount()) {
            yarp::os::Bottle* speakerInfoBottle;
            speakerInfoBottle = inputSpeakerPort.read(false);
            if (speakerInfoBottle != NULL) {
                localizationStatus = speakerInfoBottle->get(0).asString();
                speakerBin = speakerInfoBottle->get(1).asInt64(); //
                confidenceLocalization = speakerInfoBottle->get(2).asFloat64();
                audioInstance = speakerInfoBottle->get(3).asInt64();
            }
        }
    } else {

        if (inputAcapelaBookmarkPort.getInputCount()) {
            yDebug("the robot is talking\n");
            activationModulesDict["speak"] = 1;
            activationModulesDict["languageReasoning"] = 1;
            sendExpressionAction("exp", "set", "col", "green");
        } else {
            listen = true;
            sendExpressionAction("exp", "set", "col", "white");
            activationModulesDict["speak"] = 0;
            activationModulesDict["languageReasoning"] = 0;
        }
    }



    return;
}

void stateControllerXAEThread::processSpeechInfo() {

    // FROM LOCALIZATION

    if (not sound) {
        if (currentState == CLASSIFYING) {
            sendMessageAddressee("stop");
            //activationModulesDict["visualProcessing"] = 0;
            activationModulesDict["addresseeEstimation"] = 0;

        }

        activationModulesDict["soundDetection"] = 0;
        activationModulesDict["languageReasoning"] = 0;
        activationModulesDict["soundLocalization"] = 0;
        receiveAddresseeInfo();
        processAddresseeInfo();
        if (addressee) {
            //here there were receiveAddresseeInfo() and processAddresseeInfo()
        }
        speakerLocalized = false;
        speaker = false;
        addressee = false;
        localizationStatus = "";
        addresseeDirection = "";
        currentState = WAITING;
    } else {
        activationModulesDict["soundDetection"] = 1;
        if (speakerLocalized) {
            activationModulesDict["soundLocalization"] = 0;
        } else { // if speaker not localized
            activationModulesDict["soundLocalization"] = 1;
            if (localizationStatus == "finished" and not speakerLocalized) {   // SPEAKER LOCALIZED
                //sendExpressionAction("exp", "set", "col", "green");
                for (int i = 0; i < binDictZone.size(); i++) {   //here?
                    setRoleInMemory("person", binDictZone[i]);
                }
                if (speakerBin != currentBin) {
                    sendMessageAction("look", binDictZone[speakerBin], speakerBin);
                    yarp::os::Time::delay(1.0);
                    activationModulesDict["move"] = 0;
                }

                getZonesFromMemory("person");
                if (std::find(zones.begin(), zones.end(), speakerBin) != zones.end()) {
                    setRoleInMemory("speaker", binDictZone[speakerBin]);
                    speakerLocalized = true;
                    speaker = true;
                    localizationStatus = "";
                    currentState = CLASSIFYING;
                } else {
                    speakerLocalized = false;
                    speaker = false;
                    localizationStatus = "";
                    currentState = WAITING;
                }
                //currentState = CLASSIFYING;

            }
        }
    }

    return;
}

void stateControllerXAEThread::check_people_in_direction() {

    // take all the bins in list
    std::vector<int> bins_list;
    for (const auto& pair : binDictZone) {
        bins_list.push_back(pair.first);
    }

    if (addresseeDirection == "right") {
            std::sort(bins_list.begin(), bins_list.end());
        for (int i : bins_list) {
            if (i > currentBin) {
                sendMessageAction("look", binDictZone[i], i);
                yarp::os::Time::delay(1);  // todo check if enough
                activationModulesDict["move"] = 0;
            }
        }
    } else if (addresseeDirection == "left") {
        std::sort(bins_list.begin(), bins_list.end(), std::greater<int>());
        for (int i : bins_list) {
            if (i < currentBin) {
                sendMessageAction("look", binDictZone[i], i);
                yarp::os::Time::delay(1); // todo check if enough
                activationModulesDict["move"] = 0;
            }
        }

    }

}

void stateControllerXAEThread::setiCubExpressions(){

    if (addresseeDirection == "left") {
        sendExpressionAction("exp", "set", "leb", "ang");
        sendExpressionAction("exp", "set", "reb", "neu");
        sendExpressionAction("exp", "set", "col", "white");
    } else if (addresseeDirection == "right") {
        sendExpressionAction("exp", "set", "reb", "ang");
        sendExpressionAction("exp", "set", "leb", "neu");
        sendExpressionAction("exp", "set", "col", "white");
    } else if (addresseeDirection == "robot") {
        sendExpressionAction("exp", "set", "all", "hap");
        sendExpressionAction("exp", "set", "col", "red");
    }

    if (confidenceClassification > 0.8) {
        sendExpressionAction("exp", "set", "mou", "hap");
    } else {
        sendExpressionAction("exp", "set", "mou", "neu");
    }

}


void stateControllerXAEThread::run() {

    receiveSpeechInfo();
    processSpeechInfo();
    updateVisualizerInfo();

    switch (currentState) {


        case DEFAULT: {
            if (currentState != previousState) {
                cout << "DEFAULT" << endl;
            }
            previousState = currentState;
            break;
        }
        case WAITING: {
            if (currentState != previousState) {

                cout << "WAITING" << endl;

            }
            //sendMessageAddressee("sus");
            previousState = currentState;
            break;
        }

        case CLASSIFYING: {
            if (currentState != previousState) {
                sendMessageAddressee("run");
                //activationModulesDict["visualProcessing"] = 1;
                activationModulesDict["addresseeEstimation"] = 1;
                cout << "CLASSIFYING" << endl;
            }
            receiveAddresseeInfo();
            //processAddresseeInfo();
            //if (not empty(addresseeDirection)) {
            //    yInfo(addresseeDirection.c_str());
            //}

            previousState = currentState;
            break;
        }

    }


}

/******************************************************************************/




