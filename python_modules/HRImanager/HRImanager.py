import yarp
import os
import sys
import cv2
from enum import Enum

from utils.cube import Cube
from utils.State import State
from utils.object import Object

def info(msg):
    print("[INFO] {}".format(msg))

def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

def warning(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))


class HRImanager(yarp.RFModule):
    """
    Description:
        Class to manage the Interaction
    Args:
          :
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

        self.models_folder = os.path.abspath(os.path.join(__file__, "../../../models"))

        # handle port for the RFModule
        self.module_name = None
        self.handle_port = None

        # Define port
        self.bottle_in_port = yarp.BufferedPortBottle()
        self.bottle_out_port = yarp.BufferedPortBottle()
        self.cube_touch_in_port = yarp.BufferedPortBottle()
        self.cube_action_in_port = yarp.BufferedPortBottle()
        self.object_in_port = yarp.BufferedPortBottle()
        self.image_in_port = yarp.BufferedPortImageRgb()
        self.image_out_port = yarp.BufferedPortImageRgb()

        # Image parameters
        self.frame = yarp.ImageRgb()

        self.empty_architecture_path = None
        self.empty_architecture_filename = ""

        self.cube = None
        self.object = None

        self.current_state = State.INITIALIZATION

    def configure(self, rf):

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)

        # Module parameters
        self.module_name = rf.check("name", yarp.Value("HRImanager"), "module name (string)").asString()


        if rf.check("modules"):
            modules_bottle = rf.find("modules").asList()
            for n in range(modules_bottle.size()):
                self.activation_dict[modules_bottle.get(n).asString()] = 0
            print(self.activation_dict)

        self.empty_architecture_path = os.path.abspath(os.path.join(__file__, "../tools"))
        self.empty_architecture_filename = rf.check("img_filename", yarp.Value("architecture.jpg"), "module name (string)").asString()

        self.cube = Cube(self.cube_touch_in_port, self.cube_action_in_port)
        self.object = Object(self.object_in_port)

        self.current_state = State.WAITING_FOR_STIMULI

        # Create handle port to read message
        self.handle_port.open('/' + self.module_name)
        # create bottle reader port
        self.bottle_in_port.open('/' + self.module_name + '/bottle:i')
        # create bottle writer port
        self.bottle_out_port.open('/' + self.module_name + '/bottle:o')
        # create cube reader port for touch
        self.cube_touch_in_port.open('/' + self.module_name + '/cube:touch:i')
        # create cube reader port for actions
        self.cube_action_in_port.open('/' + self.module_name + '/cube:action:i')
        # create object reader port
        self.object_in_port.open('/' + self.module_name + '/object:i')
        # Create image reader port
        self.image_in_port.open('/' + self.module_name + '/image:i')
        # Create image writer port
        self.image_out_port.open('/' + self.module_name + '/image:o')

        info("Initialization complete")

        return True

    def interruptModule(self):
        print("[INFO] Stopping the module")

        self.handle_port.interrupt()
        self.bottle_in_port.interrupt()
        self.bottle_out_port.interrupt()
        self.cube_touch_in_port.interrupt()
        self.cube_action_in_port.interrupt()
        self.object_in_port.interrupt()
        self.image_in_port.interrupt()
        self.image_out_port.interrupt()

        return True

    def close(self):

        self.handle_port.close()
        self.bottle_in_port.close()
        self.bottle_out_port.close()
        self.cube_touch_in_port.close()
        self.cube_action_in_port.close()
        self.object_in_port.close()
        self.image_in_port.close()
        self.image_out_port.close()

        return True

    def respond(self, command, reply):
        # Is the command recognized
        #rec = False

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
        return 0.1

    def updateModule(self):

        #try except?



        if self.bottle_in_port.getInputCount():
            # reading image from yarp port
            input_bottle = self.bottle_in_port.read(False)
            # clock here to save timestamp
            if input_bottle is not None:
                self.read_bottle(input_bottle)
                #print(self.activation_dict)

                self.frame = self.displayArchitecture.visualize(self.activation_dict)

                if self.image_out_port.getOutputCount():
                    self.write_yarp_image()
        else:

            info("no info from the architecture")

        # STATE MACHINE
        if self.current_state == State.WAITING_FOR_STIMULI:
            self.cube.read_and_process()
            self.object.read()
            #print("waiting for stimuli")
        elif self.current_state == State.REASONING:
            print("reasoning")
        elif self.current_state == State.ACTING_TOWARD_ENVIRONMENT:
            print("action")

        return True


    def read_bottle(self, yarp_bottle):


        for n, m in enumerate(self.activation_dict.keys()):
            if n == 0:
                pass
            module = yarp_bottle.get(n).asList().get(0).asString()
            activation = yarp_bottle.get(n).asList().get(1).asInt32()
            #print(n, m, module, activation)
            self.activation_dict[module] = activation
            #if m != module:
                #warning("there might be problems while reading the bottle in input: "
                #        "check the bottle and the dictionary share the same structure")
        #else:
        #    warning("what you are reading in input is incompatible with what you expect")

        return

    def write_yarp_image(self):
        """
        Handle function to stream the recognize faces with their bounding rectangles
        :param img_array:
        :return:
        """
        display_buf_image = self.image_out_port.prepare()
        display_buf_image.setExternal(self.frame.tobytes(), self.frame.shape[1], self.frame.shape[0])
        self.image_out_port.write()

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
