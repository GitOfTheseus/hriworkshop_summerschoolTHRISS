#include <iCub/interactionInterfaceModule.h>
#include <iostream>


using namespace yarp::os;
using namespace yarp::sig;


int main(int argc, char * argv[]){

    Network yarp;
    interactionInterfaceModule module;

    ResourceFinder rf;
    rf.setVerbose(true);
    rf.setDefaultConfigFile("icub_demos.ini");      //overridden by --from parameter
    rf.setDefaultContext("icubDemos");              //overridden by --context parameter
    rf.configure(argc, argv);


    yInfo("resourceFinder: %s",rf.toString().c_str());

    module.runModule(rf);
    return 0;
}
