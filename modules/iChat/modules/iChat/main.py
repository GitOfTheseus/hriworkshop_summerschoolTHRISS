from gradio_client import Client
import yarp
import os
import sys
import re


def info(msg):
    print("[INFO] {}".format(msg))
def warn(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))
def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

# create yarp module
class iChat_Module(yarp.RFModule):
    """
    Description:
        this module is used to interact with the LLMs, it receives text and returns a reply
    Args:
        name: root module name 
        model_name: name of the model to use
        top_k: top_k parameter for the model
        top_p: top_p parameter for the model
        temperature: temperature parameter for the model
        max_tokens: max_tokens parameter for the model
        repetition_penalty: repetition_penalty parameter for the model
        system_prompt: initial context used to initialize conversation

    Ports:
        input_port  : iChat/llm/question:i
        output_port : iChat/llm/answer:o
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

    def configure(self, rf):

        self.process = True

        ## Reading Parameters ##
        self.module_name = rf.check("name",
                                    yarp.Value("iChat"),
                                    "module name (string)").asString()
        self.model_name = rf.check("model_name",
                                    yarp.Value("togethercomputer/llama-2-70b-chat"), #mistralai/Mistral-7B-Instruct-v0.1
                                    "model name (string)").asString() 
        self.top_k = rf.check("top_k",
                                    yarp.Value(50),
                                    "top_k (int)").asInt8()
        self.top_p = rf.check("top_p",
                                    yarp.Value(0.7),
                                    "top_p (float)").asFloat64()
        self.temperature = rf.check("temperature",
                                    yarp.Value(0.7),
                                    "temperature (float)").asFloat64()
        self.max_tokens = rf.check("max_tokens",
                                    yarp.Value(120),
                                    "max_tokens (int)").asInt8()
        self.repetition_penalty = rf.check("repetition_penalty",
                                    yarp.Value(1.0),
                                    "repetition_penalty (float)").asFloat64()
        self.system_prompt = rf.check("context",
                                    yarp.Value(""),
                                    "initial context used to initialize conversation(string)").asString()

        # BRUTE FORCE MODE FOR THE SUMMERSCHOOL
        self.system_prompt = """You are a robot named icub, please extract the subject (that is always an object) from this phrase and return it. output only one word. if you dont't know how to answer just reply NONE
            example: "look at this pen" -> pen
            example: "mmh pass me haha" -> NONE
            phrase: INSERT_PROMPT_HERE """

        #check that the system prompt is not empty
        if self.system_prompt == "":
            error("system_prompt cannot be empty")
            return False


        #print all the parameters
        print("\n-------------------------------------------------------")
        info("using context: {}".format(rf.getContext()))
        info("Parameters:")
        info("module_name: {}".format(self.module_name))
        info("model_name: {}".format(self.model_name))
        info("top_k: {}".format(self.top_k))
        info("top_p: {}".format(self.top_p))
        info("temperature: {}".format(self.temperature))
        info("max_tokens: {}".format(self.max_tokens))
        info("repetition_penalty: {}".format(self.repetition_penalty))
        info("system_prompt: {}".format(self.system_prompt[:50] + "..."))
        print("-------------------------------------------------------\n")
        


        # enclose the system_prompt in the right tags
        #self.prompt = f"<s>[INST] <<SYS>>{self.system_prompt}<</SYS>>\n\n"
        
        # if we use a free cloud API model from huggingface
        self.llm = Client("https://skier8402-mistral-super-fast.hf.space/")  #https://osanseviero-mistral-super-fast.hf.space/")

        # Create ports
        self.handle_port = yarp.Port()
        self.question_port = yarp.BufferedPortBottle()
        self.answer_port = yarp.Port()

        # Open ports
        self.handle_port.open('/' + self.module_name)
        self.question_port.open('/' + self.module_name + '/question:i')
        self.answer_port.open('/' + self.module_name + '/answer:o')

        info("Initialization complete")

        return True

    def getPeriod(self):
        """
           Module refresh rate.

           Returns : The period of the module in seconds.
        """
        return 0.5


    def updateModule(self):

        if self.process:

            # read the question from the user, wait until it is available
            question = self.question_port.read(shouldWait=True)

            if question is not None:
                #user_input = input("user: ")
                print("\033[1m" + "User: \033[0m" + question.toString() + "\n")

                self.input = self.system_prompt.replace('INSERT_PROMPT_HERE', question.toString())
                #print(prompt)

                # self.input = (f" <<SYS>> " + self.system_prompt +
                #  f" [INST]" + question.toString() + f"[/INST]") #
                
                print("input: ", self.input)

                
                answer = self.llm.predict(self.input,0.9,256,0.9,1.2,api_name="/chat")
                # remove end of sentence token </s>
                model_reply = answer[:-4]

                #print in bold the model reply
                print("\033[1m" + "iCub: \033[0m" + model_reply + "\n")

                # send the answer to the user
                self.send_answer(model_reply)

        return True

    def send_answer(self, text):
        if self.answer_port.getOutputCount():
            answer_bottle = yarp.Bottle()
            answer_bottle.clear()
            answer_bottle.addString(text)
            self.answer_port.write(answer_bottle)
    
    def remove_tags_and_emojis(self, text):
        # Rimuove le parti del testo racchiuse tra i tag *
        text = re.sub(r'\*.*?\*', '', text)
        # Rimuove le emoji
        text = re.sub(r'[\U00010000-\U0010ffff]', '. ', text)
        return text

    def interruptModule(self):
        info("stopping the module")
        self.handle_port.interrupt()
        self.question_port.interrupt()
        self.answer_port.interrupt()

        return True

    def close(self):
        self.handle_port.close()
        self.question_port.close()
        self.answer_port.close()

        return True

if __name__ == '__main__':

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        info("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    Module = iChat_Module()

    rf = yarp.ResourceFinder()
    rf.setVerbose(False)
    
    rf.setDefaultConfigFile('iChat_eng.ini') # name of the default .ini file
    rf.setDefaultContext('iChat') # where to find .ini files for this application

    if rf.configure(sys.argv):
        Module.runModule(rf)
    sys.exit()