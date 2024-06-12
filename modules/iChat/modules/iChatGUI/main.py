import sys
import tkinter as tk
from tkinter import scrolledtext
import threading
import yarp
import time

# To print on the terminal
def info(msg):
    print("[INFO] {}".format(msg))




class Chat(yarp.RFModule):
    """
    Description:
        This module allos to visualize a chat between the user and the robot.
    Args:
        name  : module name (string)
    Ports:
        /name/robot:i    : port to receive the robot's messages
        /name/user:i     : port to receive the user's messages
        /name/keyboard:o : port to send the user's messages from the textual chat (keyboard)
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)
        self.module_name = None

        # INPUT PORTS: one for the user input and one for robot
        self.user_port = yarp.BufferedPortBottle()

        self.robot_port = yarp.BufferedPortBottle()

        # OUTPUT PORT: publish the user input from the keyboard
        self.keyboard_port = yarp.Port()
      

    def configure(self, rf):

        # set the module state to running
        self.process = True

        # Module parameters
        self.module_name = rf.check("name",
                                    yarp.Value("iChatGUI"),
                                    "module name (string)").asString()

        # Opening Ports
        # Create handle port to read message
        self.handle_port.open('/' + self.module_name)
        # port to receive the robot's messages
        self.robot_port.open('/' + self.module_name + '/robot:i')
        # port to receive the user's messages
        self.user_port.open('/' + self.module_name + '/user:i')
        # port to send the user's messages from the textual chat (keyboard)
        self.keyboard_port.open('/' + self.module_name + '/keyboard:o')

        # Create the chat window
        self.root = tk.Tk()
        self.chat_window = self.GUI(self.root, self.keyboard_port) #I pass the keyboard port to the GUI, it wo
        #set the minimum size of the window
        self.root.minsize(450, 300)
        self.root.geometry("800x600")
        self.root.update()

        info("Initialization complete")

        return True
  

    def interruptModule(self):
        info("stopping the module")
        self.handle_port.interrupt()
        self.robot_port.interrupt()
        self.user_port.interrupt()
        self.keyboard_port.interrupt()
    
        return True


    def close(self):
        info("closing the module")
        self.handle_port.close()
        self.robot_port.close()
        self.user_port.close()
        self.keyboard_port.close()
        #close the GUI
        self.root.destroy()


        return True


    def getPeriod(self):
        """
           Module refresh rate.

           Returns : The period of the module in seconds.
        """
        return 0.2


    def updateModule(self):        

        while self.process:

            # TODO: implement a way to stop the module / clean the chat from handler port
            
            # Read the message from the robot
            robot_message = self.robot_port.read(False)

            # Read the message from the user
            user_message = self.user_port.read(False)

            # Check message from the robot
            if robot_message:
                self.chat_window.write_on_GUI(message = robot_message.toString(), sender = "iCub")

            # Check message from the user
            if user_message:
                self.chat_window.write_on_GUI(message = user_message.toString(), sender = "User")

            robot_message = None
            user_message = None

            # Update the GUI
            self.root.update()

        return True
    
    class GUI:
        def __init__(self, master, keyboard_port):

            self.output_port = keyboard_port

            self.master = master
            master.title("Chat Window")

            # Create text area for the chat messages
            self.text_area = scrolledtext.ScrolledText(master, highlightthickness=0, borderwidth=0, wrap="word", state="disabled")
            self.text_area.grid(row=0, column=0, columnspan=2, sticky="nsew")
            self.text_area.configure(font=("Arial", 24))

            # Create input field for user to enter messages
            self.input_field = tk.Entry(master)
            # make input field rounded
            self.input_field.grid(row=1, column=0, sticky="ew")
            self.input_field.configure(font=("Arial", 24))

            # Bind the Enter key to the send message function
            self.input_field.bind("<Return>", self.send_message_from_keyboard)

            # Create send button
            self.send_button = tk.Button(master, text="Send", command=self.send_message_from_keyboard, height=1, width=10)
            self.send_button.grid(row=1, column=1, sticky="e")

            # Configure grid to resize with window
            master.columnconfigure(0, weight=1)
            master.columnconfigure(1, weight=0)
            master.rowconfigure(0, weight=1)
            master.rowconfigure(1, weight=0)

            # Define Graphical User Interface
            self.text_area.tag_configure("iCub", font=("Arial", 24, "bold"), foreground="coral1")
            self.text_area.tag_configure("User", font=("Arial", 24, "bold"), foreground="dodgerblue1")
            #tag for formatting the message
            self.text_area.tag_configure("Message", font=("Arial", 24))


            # FIXME: move this to a separate function
            # self.keyboard_port = yarp.Port()
            # self.keyboard_port.open('/' + 'iChatGUI' + '/keyboard:o')

            # callback that sends a message from the input field (Keyboard input) to the chat 

        def send_message_from_keyboard(self, event=None):
            # Get the user's message from the input field
            message = self.input_field.get()

            # Check if the input field is empty
            if not message:
                return
            else:
                #send message on YARP
                key_bottle = yarp.Bottle()
                key_bottle.clear()
                key_bottle.addString(message)
                self.output_port.write(key_bottle)

                #add message to GUI
                self.write_on_GUI(message=message, sender="User")

            # Clear the input field
            self.input_field.delete(0, tk.END)



        def write_on_GUI(self, message, sender):

            self.text_area.configure(state="normal")

            #print the name of the agent, use the tag to format the name
            self.text_area.insert(tk.END, sender + "\n", sender)
            #print the message
            self.text_area.insert(tk.END, f"{message}\n", "Message")
        
            #FIXME: do we need this ?
            #self.text_area.configure(state="disabled")

            ###############################################
            # # Adjust the font size to fit the window
            # #get the current size of the window
            # width = self.master.winfo_width()
            # height = self.master.winfo_height()
            # #calculate the font size based on the window size
            # font = ("Arial", int(height / 10))
            # #update the font size of the GUI
            # self.text_area.configure(font=font)
            # self.input_field.configure(font=font)
            ###############################################

            #scroll the text area to the bottom
            self.text_area.see(tk.END)
            

if __name__ == '__main__':

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        info("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    Module = Chat()

    rf = yarp.ResourceFinder()
    rf.setVerbose(True)
    rf.setDefaultContext('chatGUI') # where to find .ini files for this application
    rf.setDefaultConfigFile('chatGUI.ini') # name of the default .ini file NO, NAME OF THE FOLDER

    if rf.configure(sys.argv):
        Module.runModule(rf)
    sys.exit()
