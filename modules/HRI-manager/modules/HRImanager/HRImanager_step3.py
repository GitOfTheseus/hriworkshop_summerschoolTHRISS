import yarp
import sys

from utils.cube import Cube
from utils.state import State
from utils.objectReader import ObjectReader
from utils.actions import Action
from utils.speech import Speech
from utils.memory import Memory
from utils.world import World

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

        # handle port for the RFModule
        self.module_name = None
        self.handle_port = None

        # Define port
        self.cube_event_in_port = yarp.BufferedPortBottle()
        self.action_rpc_port = yarp.RpcClient()
        self.action_rpc_port.setRpcMode(True)
        self.gaze_rpc_port = yarp.RpcClient()
        self.gaze_rpc_port.setRpcMode(True)
        self.obj_in_port = yarp.BufferedPortBottle()
        self.text_in_port = yarp.BufferedPortBottle()
        self.bookmark_out_port = yarp.Port()
        self.LLM_out_port = yarp.Port()
        self.LLM_in_port = yarp.BufferedPortBottle()
        self.speech_out_port = yarp.Port()
        self.world_rpc_port = yarp.RpcClient()
        self.world_rpc_port.setRpcMode(True)

        self.text = ""
        self.object_class_dict = {}
        self.object_class_list = []
        self.object_position = None
        self.object_direction = ""
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

        # Module name
        self.module_name = rf.check("name", yarp.Value("HRImanager"), "module name (string)").asString()

        # Create input output and rpc ports and give them names
        self.handle_port.open('/' + self.module_name)
        self.cube_event_in_port.open('/' + self.module_name + '/cube:event:i')
        self.action_rpc_port.open('/' + self.module_name + '/action:rpc')
        self.gaze_rpc_port.open('/' + self.module_name + '/gaze:rpc')
        self.obj_in_port.open('/' + self.module_name + '/objects:i')
        self.text_in_port.open('/' + self.module_name + '/text:i')
        self.bookmark_out_port.open('/' + self.module_name + '/bookmark:o')
        self.LLM_out_port.open('/' + self.module_name + '/LLM:o')
        self.LLM_in_port.open('/' + self.module_name + '/LLM:i')
        self.speech_out_port.open('/' + self.module_name + '/speech:o')
        self.world_rpc_port.open('/' + self.module_name + '/world:rpc')

        # create objects to manage the different parts of the architecture
        self.cube = Cube(self.cube_event_in_port)
        self.action = Action(self.action_rpc_port, self.gaze_rpc_port, self.speech_out_port)
        self.objectReader = ObjectReader(self.obj_in_port, self.gaze_rpc_port)
        self.speech = Speech(self.text_in_port, self.bookmark_out_port, self.LLM_out_port, self.LLM_in_port)
        self.memory = Memory()
        self.world = World(self.world_rpc_port)

        # connect ports
        if not self.ports_connection():
            error("exiting for problems in port connections")
            return False

        # final configuration before starting the thread
        self.action.execute("go_home_human")
        self.world.save_coordinates()
        self.memory.retrieve_long_term_memory()
        self.current_state = State.WAITING_FOR_STIMULI

        info("Initialization complete")

        return True

    def interruptModule(self):

        self.ports_disconnection()

        info("Stopping the module")

        self.handle_port.interrupt()
        self.cube_event_in_port.interrupt()
        self.action_rpc_port.interrupt()
        self.gaze_rpc_port.interrupt()
        self.obj_in_port.interrupt()
        self.text_in_port.interrupt()
        self.bookmark_out_port.interrupt()
        self.LLM_out_port.interrupt()
        self.LLM_in_port.interrupt()
        self.speech_out_port.interrupt()
        self.world_rpc_port.interrupt()

        return True

    def close(self):

        self.handle_port.close()
        self.cube_event_in_port.close()
        self.action_rpc_port.close()
        self.gaze_rpc_port.close()
        self.obj_in_port.close()
        self.text_in_port.close()
        self.bookmark_out_port.close()
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

            self.object_class_list = self.objectReader.read()
            if self.object_class_list:
                self.object_class_list = [obj for obj in self.object_class_list if obj != "person"]
                info(f"I detected the following categories of objects {self.object_class_list}")
                if len(self.object_class_list) > 0:
                    self.object_class_dict = self.objectReader.localize()

                    if self.object_class_dict:
                        self.changeState(State.REASONING)

        elif self.current_state == State.REASONING:

            for obj in self.object_class_list:

                if obj in list(self.object_class_dict.keys()):
                    self.object_category = obj
                    self.object_position = self.object_class_dict[obj]

                    self.object_direction = self.objectReader.discretized_position(self.object_position)
                    self.text = self.speech.listen()
                    if self.text:
                        self.object_name = self.speech.reason(self.text)

                        self.memory.store_working_memory(self.object_category, object_position=self.object_position,
                                                         object_direction=self.object_direction, name=self.object_name)
                    else:
                        self.memory.store_working_memory(self.object_category, object_position=self.object_position,
                                                         object_direction=self.object_direction)
                    self.memory.store_long_term_memory()
                    self.changeState(State.ACTING_TOWARD_ENVIRONMENT)

                    break

                else:
                    self.object_position = ()
                    self.object_direction = ""
                    info(f"no {obj} in the simulated environment")
                    self.changeState(State.WAITING_FOR_STIMULI)

        elif self.current_state == State.ACTING_TOWARD_ENVIRONMENT:

            self.action.look(self.memory.retrieve_information(self.object_category, 'position'))
            self.action.execute(f"point_{self.memory.retrieve_information(self.object_category, 'direction')}")
            yarp.delay(1.5)
            self.action.execute("go_home_human")
            self.changeState(State.WAITING_FOR_STIMULI)

        return True

    def changeState(self, new_state):

        self.current_state = new_state

        return

    def ports_connection(self):

        # vision
        if not self.establish_connection('/icubSim/cam/left/rgbImage:o', '/objectRecognition/image:i'):
            return False

        if not self.establish_connection('/objectRecognition/objects:o', self.obj_in_port.getName()):
            return False

        if not self.establish_connection('/webcam', '/view:webcam'):
            return False

        if not self.establish_connection('/icubSim/cam/left/rgbImage:o', '/view:sim'):
            return False

        if not self.establish_connection('/objectRecognition/annotated_image:o', '/view:obj'):
            return False

        # haptic
        """if not self.establish_connection('/icube/events:o', '/HRImanager/cube:event:i'):
            return False"""

        if not self.establish_connection(self.world_rpc_port.getName(), '/world_input_port'):
            return False

        # speech
        if not self.establish_connection(self.bookmark_out_port.getName(), '/speech2text/bookmark:i'):
            return False

        if not self.establish_connection('/speech2text/text:o', self.text_in_port.getName()):
            return False

        if not self.establish_connection(self.LLM_out_port.getName(), '/iChat/question:i'):
            return False

        if not self.establish_connection('/iChat/answer:o', self.LLM_in_port.getName()):
            return False

        """if not self.establish_connection(self.speech_out_port.getName(), "/text2speech/text:i"):
            return False"""

        # actions
        if not self.establish_connection(self.action_rpc_port.getName(), '/interactionInterface'):
            return False

        if not self.establish_connection(self.gaze_rpc_port.getName(), '/iKinGazeCtrl/rpc'):
            return False

        return True

    def establish_connection(self, port_input, port_output):

        if yarp.Network.exists(port_input):
            if yarp.Network.exists(port_output):
                yarp.Network.connect(port_input, port_output)
                return True
            else:
                warning(f"check for correct opening of module {port_output.split('/')[1]}")
                error(f"{port_output} does not exist")
                return False
        else:
            warning(f"check for correct opening of module {port_input.split('/')[1]}")
            error(f"{port_input} does not exist")
            return False

    def ports_disconnection(self):

        # vision
        yarp.Network.disconnect('/icubSim/cam/left/rgbImage:o', '/objectRecognition/image:i')
        yarp.Network.disconnect('/webcam', '/objectRecognition/image:i')
        yarp.Network.disconnect('/objectRecognition/objects:o', self.obj_in_port.getName())

        # haptic
        yarp.Network.disconnect('/icube/events:o', '/HRImanager/cube:event:i')
        yarp.Network.disconnect(self.world_rpc_port.getName(), '/world_input_port')

        # speech
        yarp.Network.disconnect(self.bookmark_out_port.getName(), '/speech2text/bookmark:i')
        yarp.Network.disconnect('/speech2text/text:o', self.text_in_port.getName())
        yarp.Network.disconnect(self.LLM_out_port.getName(), '/iChat/question:i')
        yarp.Network.disconnect('/iChat/answer:o', self.LLM_in_port.getName())
        yarp.Network.disconnect(self.speech_out_port.getName(), "/text2speech/text:i")

        # actions
        yarp.Network.disconnect(self.action_rpc_port.getName(), '/interactionInterface')
        yarp.Network.disconnect(self.gaze_rpc_port.getName(), '/iKinGazeCtrl/rpc')

        return True


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
