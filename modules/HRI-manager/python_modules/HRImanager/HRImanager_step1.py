import yarp
import os
import sys
#import cv2
from enum import Enum

from utils.cube import Cube
from utils.state import State
from utils.objectReader import ObjectReader
from utils.actions import Action
from utils.speech import Speech
from utils.world import World

def info(msg):
    print("[INFO] {}".format(msg))

def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

def warning(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))

def debug(msg):
    print("\033[92m[DEBUG] {}\033[00m".format(msg))


class HRImanager(yarp.RFModule):
    """
    Description:
        Class to manage the Interaction
    Args:
          :
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

        # handle port for the RFModule
        self.module_name = None
        self.handle_port = None

        # Define port
        self.bottle_in_port = yarp.BufferedPortBottle()
        self.bottle_out_port = yarp.BufferedPortBottle()
        self.cube_touch_in_port = yarp.BufferedPortBottle()
        self.cube_event_in_port = yarp.BufferedPortBottle()
        self.action_rpc_port = yarp.RpcClient()
        self.action_rpc_port.setRpcMode(True)
        self.gaze_rpc_port = yarp.RpcClient()
        self.gaze_rpc_port.setRpcMode(True)
        self.gaze_in_port = yarp.BufferedPortBottle()
        self.obj_webcam_in_port = yarp.BufferedPortBottle()
        self.obj_sim_in_port = yarp.BufferedPortBottle()
        self.text_in_port = yarp.BufferedPortBottle()
        self.LLM_out_port = yarp.BufferedPortBottle()
        self.LLM_in_port = yarp.BufferedPortBottle()
        self.speech_out_port = yarp.BufferedPortBottle()
        self.world_rpc_port = yarp.RpcClient()
        self.world_rpc_port.setRpcMode(True)

        self.text = ""
        self.object_class_dict = {}
        self.object_class_list = []
        self.focus_position = None
        self.object_position = ""
        self.object_category = ""
        self.text = ""

        self.cube = None
        self.action = None
        self.objectReader = None
        self.speech = None
        self.memory = None
        self.world = None

        self.current_state = State.INITIALIZATION

    def configure(self, rf):

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)

        # Module parameters
        self.module_name = rf.check("name", yarp.Value("HRImanager"), "module name (string)").asString()

        # Create handle port to read message
        self.handle_port.open('/' + self.module_name)
        # create bottle reader port
        self.bottle_in_port.open('/' + self.module_name + '/bottle:i')
        # create bottle writer port
        self.bottle_out_port.open('/' + self.module_name + '/bottle:o')
        # create cube reader port for touch
        self.cube_touch_in_port.open('/' + self.module_name + '/cube:touch:i')
        # create cube reader port for actions
        self.cube_event_in_port.open('/' + self.module_name + '/cube:event:i')
        # create object reader port
        self.action_rpc_port.open('/' + self.module_name + '/action:rpc')
        self.gaze_rpc_port.open('/' + self.module_name + '/gaze:rpc')
        self.gaze_in_port.open('/' + self.module_name + '/gaze:i')
        self.obj_webcam_in_port.open('/' + self.module_name + '/object:webcam:i')
        self.obj_sim_in_port.open('/' + self.module_name + '/object:sim:i')
        self.text_in_port.open('/' + self.module_name + '/text:i')
        self.LLM_out_port.open('/' + self.module_name + '/LLM:o')
        self.LLM_in_port.open('/' + self.module_name + '/LLM:i')
        self.speech_out_port.open('/' + self.module_name + '/speech:o')
        self.world_rpc_port.open('/' + self.module_name + '/world:rpc')


        self.cube = Cube(self.cube_touch_in_port, self.cube_event_in_port)
        self.action = Action(self.action_rpc_port, self.gaze_rpc_port, self.gaze_in_port, self.speech_out_port)
        self.objectReader = ObjectReader(self.obj_webcam_in_port, self.obj_sim_in_port, self.gaze_rpc_port)
        self.speech = Speech(self.text_in_port, self.LLM_out_port, self.LLM_in_port)
        self.world = World(self.world_rpc_port)

        try:
            yarp.Network.connect('/' + self.module_name + '/gaze:rpc', "/iKinGazeCtrl/rpc")
            self.action.look_table()
        except Exception as e:
            error("Unable to connect to the gaze port with iKinGazeCtrl: " + str(e))
            return False

        try:
            yarp.Network.connect('/' + self.module_name + '/world:rpc', "/world_input_port")
            self.world.get_coordinates()
        except Exception as e:
            error("Unable to connect to the world port with gazebo: " + str(e))
            return False

        self.current_state = State.WAITING_FOR_STIMULI

        info("Initialization complete")

        return True

    def interruptModule(self):

        info("Stopping the module")

        self.handle_port.interrupt()
        self.bottle_in_port.interrupt()
        self.bottle_out_port.interrupt()
        self.cube_touch_in_port.interrupt()
        self.cube_event_in_port.interrupt()
        self.action_rpc_port.interrupt()
        self.gaze_rpc_port.interrupt()
        self.gaze_in_port.interrupt()
        self.obj_webcam_in_port.interrupt()
        self.obj_sim_in_port.interrupt()
        self.text_in_port.interrupt()
        self.LLM_out_port.interrupt()
        self.LLM_in_port.interrupt()
        self.speech_out_port.interrupt()
        self.world_rpc_port.interrupt()

        return True

    def close(self):

        self.handle_port.close()
        self.bottle_in_port.close()
        self.bottle_out_port.close()
        self.cube_touch_in_port.close()
        self.cube_event_in_port.close()
        self.action_rpc_port.close()
        self.gaze_rpc_port.close()
        self.gaze_in_port.close()
        self.obj_webcam_in_port.close()
        self.obj_sim_in_port.close()
        self.text_in_port.close()
        self.LLM_out_port.close()
        self.LLM_in_port.close()
        self.speech_out_port.close()
        self.world_rpc_port.close()

        info("Doors closed")

        return True

    def respond(self, command, reply):

        reply.clear()

        if command.get(0).asString() == "help":
            reply.addString("available commands are: \n "
                            "quit: to quit the module \n"
                            "help: to list the commands ")

        elif command.get(0).asString() == "quit":
            reply.addString("quitting")
            return False

        else:
            reply.addString("Wrong command. \n"
                            "Write help to see options. Otherwise quit, if you want to quit the module.")

        return True

    def getPeriod(self):
        """
           Module refresh rate.

           Returns : The period of the module in seconds.
        """
        return 0.5

    def updateModule(self):

        if self.current_state == State.WAITING_FOR_STIMULI:

            event = self.cube.read_and_process()
            if event:
                self.world.update_world(event)
                debug(event)

            self.focus_position = self.objectReader.focus()

            if event and self.focus_position:
                self.changeState(State.ACTING_TOWARD_ENVIRONMENT)
            elif not self.objectReader.see_objects:
                self.action.look_table()
                debug("looking at the table again")

        elif self.current_state == State.ACTING_TOWARD_ENVIRONMENT:

            self.action.look(self.focus_position)

            debug("motion completed")
            self.changeState(State.WAITING_FOR_STIMULI)

            #if self.action.check_gaze_motion_completed(self.focus_position):
                #pass

        return True


    def changeState(self, new_state):

        self.current_state = new_state

        return


if __name__ == '__main__':

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        info("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    manager = HRImanager()

    rf = yarp.ResourceFinder()
    rf.setVerbose(True)
    rf.setDefaultContext('HRIworkshopTHRISS')
    rf.setDefaultConfigFile("HRImanager.ini")

    if rf.configure(sys.argv):
        manager.runModule(rf)

    manager.close()
    sys.exit()