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

#include <iCub/interactionInterfaceModule.h>

// general command vocab's
#define COMMAND_VOCAB_OK     createVocab32('o','k')

#define COMMAND_VOCAB_SET    createVocab32('s','e','t')
#define COMMAND_VOCAB_GET    createVocab32('g','e','t')
#define COMMAND_VOCAB_SIM    createVocab32('S','I','M')
#define COMMAND_VOCAB_CLR    createVocab32('C','L','R')
#define COMMAND_VOCAB_EXE    createVocab32('e','x','e')

#define COMMAND_VOCAB_LIST   createVocab32('l','i','s','t')
#define COMMAND_VOCAB_HELP   createVocab32('h','e','l','p')
#define COMMAND_VOCAB_FAILED createVocab32('f','a','i','l')
#define COMMAND_VOCAB_SYNC   createVocab32('S','Y','N','C')
#define COMMAND_VOCAB_REPS   createVocab32('R','E','P','S')
#define COMMAND_VOCAB_LOAD   createVocab32('l','o','a','d')
#define COMMAND_VOCAB_SAVE   createVocab32('S','A','V','E')
#define COMMAND_VOCAB_FILE   createVocab32('f','i','l','e')
#define COMMAND_VOCAB_PLAY   createVocab32('p','l','a','y')
#define COMMAND_VOCAB_STOP   createVocab32('s','t','o','p')

using namespace yarp::os;
using namespace yarp::sig;
using namespace std;

/*
 * Configure method. Receive a previously initialized
 * resource finder object. Use it to configure your module.
 * If you are migrating from the old Module, this is the
 *  equivalent of the "open" method.
 */

bool interactionInterfaceModule::configure(yarp::os::ResourceFinder &rf) {

    if (rf.check("help")) {
        printf("HELP \n");
        printf("====== \n");
        printf("--name           : changes the rootname of the module ports \n");
        printf("--robot          : changes the name of the robot where the module interfaces to  \n");
        printf("--name           : rootname for all the connection of the module \n");
        printf("--config       : path of the script to execute \n");
        printf(" \n");
        printf("press CTRL-C to stop... \n");
        return true;
    }

    /* get the module name which will form the stem of all module port names */
    moduleName = rf.check("name",
                          Value("/interactionInterface"),
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
                         "Robot name (string)").asString();

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

    bool runthread = false;

    if (rf.check("config")) {
        configFile = rf.findFile(rf.find("config").asString().c_str());
        if (configFile.empty()) {
            return false;
        } else {
            scriptName = configFile;

            /* create the thread and pass pointers to the module parameters */
            rThread = new interactionInterfaceThread(scriptName, robotName, rf);
        }

    } else {
        configFile.clear();
        cout << " No script passed to the program...." << endl;
        cout << " To use exe command provide a script with --config parameter" << endl;
        configFile = "";

        /* create the thread and pass pointers to the module parameters */
        rThread = new interactionInterfaceThread();
    }

    rThread->setName(getName().c_str());

    /* now start the thread to do the work */
    runthread = rThread->start(); // this calls threadInit() and it if returns true, it then calls run()

    return runthread;       // let the RFModule know everything went well
    // so that it will then run the module
}

bool interactionInterfaceModule::close() {
    handlerPort.interrupt();
    handlerPort.close();
    /* stop the thread */
    printf("stopping the thread \n");
    rThread->onStop();
    rThread->stop();
    delete rThread;
    return true;
}

bool interactionInterfaceModule::interruptModule() {
    handlerPort.interrupt();
    return true;
}


bool interactionInterfaceModule::respond(const Bottle &command, Bottle &reply) {
    vector<string> replyScript;
    string helpMessage = string(getName().c_str()) +
                         " commands are: \n" +
                         "help \n" +
                         "quit \n";
    reply.clear();

    if (command.get(0).asString() == "quit") {
        reply.addString("quitting");
        return false;
    }


    bool ok = false;
    bool rec = false; // is the command recognized?

    mutex.wait();

    switch (command.get(0).asVocab32()) {
        case COMMAND_VOCAB_HELP:
            rec = true;
            {
                reply.addVocab32(Vocab32::encode("many"));
                reply.addString("This is an interaction interface module connecting with a script given in parameters");
                reply.addString("exe <command> [args] -> executes the commands form the script file");
                reply.addString("exe list -> show all the available commands from the loaded script");
                reply.addString("load <script.sh> -> change the loaded script at runtime (IT MUST BE RUNNABLE)");
                reply.addString("play <absolute_path_audio_file> -> play the audio file with VLC");
                ok = true;
            }
            break;

        case COMMAND_VOCAB_SET:
            rec = true;
            {
                switch (command.get(1).asVocab32()) {

                    default:
                        cout << "received an unknown request after SET" << endl;
                        break;
                }
            }
            break;

        case COMMAND_VOCAB_GET:
            rec = true;
            {
                switch (command.get(1).asVocab32()) {

                    default:
                        cout << "received an unknown request after a GET" << endl;
                        break;
                }
            }
            break;


        case COMMAND_VOCAB_EXE: {
            rec = true;
            reply.addVocab32(Vocab32::encode("many"));

            if (!configFile.empty()) {

                
                if(command.size() == 2)
                    replyScript = rThread->exec(command.get(1).asString());
                else{
                    Bottle toExec = command.tail();
                    replyScript = rThread->exec(toExec.get(0).asString(), toExec.tail());                }


                for (const auto &i : replyScript) {
                    reply.addString(i);
                }
            }

            else {
                reply.addString("No config passed to the Module can't execute command");
            }


            ok = true;
            break;
        }
        case COMMAND_VOCAB_LIST: {
            rec = true;
            reply.addVocab32(Vocab32::encode("many"));

            if (!configFile.empty()) {
                replyScript = rThread->exec("list");
                
                reply.addString("Available Commands");
                reply.addString("------------------");

                for (const auto &i : replyScript) {
                    reply.addString(i);
                }

                reply.addString("------------------");
            }

            else {
                reply.addString("No config passed to the Module can't execute command");
            }


            ok = true;
            break;
        }
        case COMMAND_VOCAB_PLAY: {

            rec = true;
            int processPID;
            const string audiofile = command.get(1).asString();
            const bool launchAudio = rThread->playAudioFile(audiofile,processPID);
            reply.addVocab32(Vocab32::encode("many"));


            if (launchAudio) {
                reply.addString("Launch audio file " + audiofile);
                reply.addInt8(processPID);
            } else {
                reply.addString("Fail to launch audio file " + audiofile);
            }

            ok = true;
            break;

        }
        case COMMAND_VOCAB_STOP:{
            rec = true;
            bool stop = false;
            if(command.size() == 2){
                stop =rThread->stopAudio(command.get(1).asInt8());

            }
            else{
                stop = rThread->stopAllAudio();
            }

            if (stop) {
                reply.addString("All files Stopped");
            } else {
                reply.addString("Fail to stop Files ");
            }
            ok = true;
            break;
        }

        case COMMAND_VOCAB_SAVE:
            rec = true;
            {
                switch (command.get(1).asVocab32()) {


                    default:
                        cout << "received an unknown request" << endl;
                        break;
                }

                ok = true;
            }
            break;
        case COMMAND_VOCAB_LOAD:
            rec = true;
            {
                if (command.get(1).asVocab32() == COMMAND_VOCAB_FILE) {
                    if (nullptr != rThread) {

                        if(rThread->loadFile(command.get(2).asString())){
                            reply.addString("OK");

                        }

                        else{
                            reply.addString("File path doesn't exist impossible to load it");


                        }

                    }
                    ok = true;
                }
            }
            break;
        case COMMAND_VOCAB_REPS:
            rec = true;
            {
                if (nullptr != rThread && command.get(1).asInt8() != 0) {
                    reply.addString("OK");

                    //rThread->setRepsNumber(command.get(1).asInt8());

                }
                ok = true;
            }
            break;

        case COMMAND_VOCAB_SYNC: {
            rec = true;
            if (nullptr != rThread) {
                reply.addString("OK");

                //rThread->setPartnerTime(0.0);

            }
            ok = true;
        }
            break;

        case COMMAND_VOCAB_SIM:
            rec = true;
            {
                switch (command.get(1).asVocab32()) {

                    case COMMAND_VOCAB_CLR: {
                        if (nullptr != rThread) {
                            reply.addString("OK");

                        }
                        ok = true;
                    }
                        break;
                    default:
                        break;
                }

            }
            break;

        default:
            break;

    }
    mutex.post();

    if (!rec)
        ok = RFModule::respond(command, reply);

    if (!ok) {
        reply.clear();
        reply.addVocab32(COMMAND_VOCAB_FAILED);
    } else
        reply.addVocab32(COMMAND_VOCAB_OK);

    return ok;


}

/* Called periodically every getPeriod() seconds */
bool interactionInterfaceModule::updateModule() {
    return true;
}

double interactionInterfaceModule::getPeriod() {
    /* module periodicity (seconds), called implicitly by myModule */
    return 1.0;
}

