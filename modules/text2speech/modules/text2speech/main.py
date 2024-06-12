import edge_tts
import subprocess
import yarp
import sys

def info(msg):
    print("[INFO] {}".format(msg))

def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

def warning(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))

class Text2SpeechModule(yarp.RFModule):
    """
    Description:
        Object to read text and vocalize it

    Args:
        input_port  : text
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

        # initialize variables
        self.timer = None

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)

        self.input_port = yarp.BufferedPortBottle()

    def configure(self, rf: yarp.ResourceFinder) -> bool:

        if rf.check('help') or rf.check('h'):
            print("text2speech options:")
            print("\t--name (default text to speech) module name")
            print("\t--language (default en)")
            print("\t--help print this help")
            return False

        self.process = rf.check('process', yarp.Value(True), 'enable automatic run').asBool()

        self.module_name = rf.check("name",
                                    yarp.Value("text2speech"),
                                    "module name (string)").asString()
        
        self.lang = rf.check('language', yarp.Value('english'),
                                   'language to vocalize: either en/it/..').asString()

        self.speaker = rf.check('speaker', yarp.Value("en-US-EricNeural"),
                                  'name of the speaker').asString()
        
        self.output_file = "test.mp3"
        
        # Handle port
        self.handle_port.open('/' + self.module_name)

        # Input port for images
        self.input_port.open('/' + self.module_name + '/text:i')

        info('Module initialization done, Running the model')

        return True

    def play_mp3(self,file_path):
        """Play the mp3 file using mpv player"""
        try:
            subprocess.run(['ffplay', '-autoexit', '-nodisp', file_path])
        except Exception as e:
            print(f"Errore durante la riproduzione del file: {e}")        

    def updateModule(self):

        if self.process:
            # Read image from port
            message = self.input_port.read(False)

            if message is not None:

                # Read the text                
                text = message.toString()
                info(f"Received text: {text}")
                communicate = edge_tts.Communicate(text, self.speaker)
                communicate.save_sync(self.output_file)
                self.play_mp3(self.output_file)

                    
        return True

    def respond(self, command, reply):       
        reply.clear()

        if command.get(0).asString() == "quit":
            reply.addString("quitting")
            return False

        elif command.get(0).asString() == "help":
            reply.addString("Text2Speech module command are:\n")
            reply.addString("set/get language <double> -> to get/set the current language\n")
            reply.addString("set/get speaker <string> -> to get/set the current speaker \n")

        elif command.get(0).asString() == "process":
            self.process = True if command.get(1).asString() == 'on' else False
            reply.addString("ok")

        return True

    def getPeriod(self):
        """
           Module refresh rate.
           Returns : The period of the module in seconds.
        """
        return 0.1
    
    def interruptModule(self):
        print("stopping the module \n")
        self.handle_port.interrupt()
        self.input_port.interrupt()
        
        return True

    def close(self):
        print("closing the module \n")
        self.handle_port.close()
        self.input_port.close()

        return True

if __name__ == '__main__':

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        print("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    objectRecognitionModule = Text2SpeechModule()

    rf = yarp.ResourceFinder()
    rf.setVerbose(True)
    rf.setDefaultContext('text2speech')
    rf.setDefaultConfigFile('text2speech.ini')

    if rf.configure(sys.argv):
        objectRecognitionModule.runModule(rf)
    sys.exit()
