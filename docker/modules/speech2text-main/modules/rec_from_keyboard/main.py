import yarp
import sys
from pynput import keyboard

def print_yellow(text):
    print("\033[93m{}\033[00m".format(text))
def info(msg):
    print("[INFO] {}".format(msg))
def warn(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))
def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

# create yarp module
class Module(yarp.RFModule):

    def __init__(self):
        yarp.RFModule.__init__(self)

    def configure(self, rf):
        # Create port
        self.keyboard_port = yarp.Port()
        self.keyboard_port.open('/keyboard:o')

        info("Initialization complete")

        return True
    
    def on_press(self,key):
        info(f'{key} pressed')
        self.send_message(1)

    def on_release(self,key):
        info(f'{key} released')
        self.send_message(0)
        if key == keyboard.Key.esc:
            # Stop listener
            return False

    def updateModule(self):
        print_yellow("Press 'esc' to stop.")

         # Collect events until released, 
        with keyboard.Listener(on_press=self.on_press, on_release=self.on_release) as self.listener:
            self.listener.join()
        
        return True
    
    def send_message(self, message):
        # Send message
        output = yarp.Bottle()
        output.addInt16(message)
        self.keyboard_port.write(output)

    def interruptModule(self):
        info("stopping the module")
        self.keyboard_port.interrupt()
        #pause the thread
        self.listener.pause()
        
        return True

    def close(self):
        info("closing the module")
        self.keyboard_port.close()
        #kill thread
        self.listener.stop()

        return True
    
    def getPeriod(self):
        """
            Module refresh rate.

            Returns : The period of the module in seconds.
        """
        return 0.1
    
if __name__ == '__main__':

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        info("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    Module = Module()

    rf = yarp.ResourceFinder()
    rf.setVerbose(True)
    
    #rf.setDefaultConfigFile('config.ini') # not implemented 
    #rf.setDefaultContext('context') # not implemented

    if rf.configure(sys.argv):
        Module.runModule(rf)
    sys.exit()
