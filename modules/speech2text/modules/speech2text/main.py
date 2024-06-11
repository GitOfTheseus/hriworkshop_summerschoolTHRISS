import os
import time
import threading
import sys

import speech_recognition as sr
from YARP_microphone_class import YARP_Microphone
from huggingface_hub import hf_hub_download
import yarp


# To print on the terminal
def info(msg):
    """Print an information message in yellow"""
    print(f"\033[93m[INFO]{msg}\033[0m")

def error(msg):
    """Print an error message in red"""
    print(f"\033[91m[ERROR]{msg}\033[0m")

class Speech2textModule(yarp.RFModule):
    """
    Description:
        This module is a wrapper for OPENAI's WHISPER MODEL library. It records audio and then uses the model to recognize the speech.
    Arguments:
        --name: module name (string)
        --model: model to use (string)
        --language: uncapitalized full language name like 'english' or 'chinese' (string)
        --energy: energy level for mic to detect (int)
        --dynamic_energy: flag to enable dynamic energy (bool)
        --pause: pause time before entry ends (float)
        --phrase_time_limit: maximum duration of the recorded phrase in seconds (int)
        --save_audio_dir: where to log audio speech (string)
        --save_file: whether to save the audio file clips (bool)
        --use_local_mic: whether to use local microphone, not exposing the audio source on a Yarp port (bool)

    Ports:
        /speech2text/speech:i receives the audio from the microphone
        /speech2text/bookmark:i receives a bookmark from acapelaSpeak module to know when iCub is speaking
        /speech2text/text:o sends the recognized text
    """

    def __init__(self):
        yarp.RFModule.__init__(self)
        self.process = True
        self.listening = True
        self.thread = None

        #define variables used in configure
        self.module_name=""
        self.key_phrase=""
        self.model=""
        self.language=""
        self.energy=0
        self.dynamic_energy=False
        self.pause=0
        self.phrase_time_limit=0
        self.save_audio_dir=""
        self.save_file=False
        self.use_local_mic=True
        self.microphone = None
        self.acapela_synch = False
        self.thread = None


        # speech recognizer object
        self.r = sr.Recognizer()

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)

        # input port for the bookmark
        self.bookmark_port = yarp.BufferedPortBottle()
        # input port for the speech
        self.speech_port = yarp.BufferedPortBottle()
        # output port for the text
        self.text_port = yarp.Port()

    def configure(self, rf):
        # Module parameters from the RFModule
        self.module_name = rf.check(
            "name", yarp.Value("speech2text"), "module name (string)"
        ).asString()
        self.key_phrase = rf.check(
            "key phrase",
            yarp.Value("Hey robot"),
            "key phrase to activate recognition e.g. 'hey robot!' (string)",
        ).asString()
        self.model = rf.check(
            "model", yarp.Value("tiny.en"), "model to use (string)"
        ).asString()
        # example of supported languages: english, italian... If NONE it will try to detect all languages
        self.language = rf.check(
            "language",
            yarp.Value("english"),
            "uncapitalized full language name like 'english' or 'chinese' (string)",
        ).asString()
        self.energy = rf.check(
            "energy",
            yarp.Value(1000),  # su iCub era 5000
            "energy level for mic to detect (int)",
        ).asFloat32()
        self.dynamic_energy = rf.check(
            "dynamic_energy", yarp.Value(False), "flag to enable dynamic energy (bool)"
        ).asBool()
        self.pause = rf.check(
            "pause", yarp.Value(0.6), "pause time before entry ends (float)"
        ).asFloat32()
        self.phrase_time_limit = rf.check(
            "phrase_time_limit",
            yarp.Value(5),
            "maximum duration of the recorded phrase in seconds (int)",
        ).asInt32()
        self.save_audio_dir = rf.check(
            "save_audio_dir", yarp.Value(""), "where to log audio speech (string)"
        ).asString()
        self.save_file = rf.check(
            "save_file",
            yarp.Value(False),
            "whether to save the audio file clips (bool)",
        ).asBool()
        self.use_local_mic = rf.check(
            "use_local_mic",
            yarp.Value(True),
            "whether to use local microphone, not exposing the audio source on a Yarp port",
        ).asBool()

        # open the microphone
        if self.use_local_mic:
            self.microphone = sr.Microphone(sample_rate=16000)
        else:
            self.microphone = YARP_Microphone()

        # check that .en models are not run with other languages
        if self.model[-3:] == ".en":
            if self.language != "english":
                error(".en models are only available for english language")
                return False

        # Set inference device
        # device = "cuda" if torch.cuda.is_available() else "cpu"

        # if the model is distil (X6 faster than original), load it from huggingface hub
        if self.model == "large-distil":
            self.model = hf_hub_download(
                repo_id="distil-whisper/distil-large-v2", filename="original-model.bin"
            )
        # else:
        #     self.model = whisper.load_model(self.model_size, device=device)

        ### Opening Ports ###
        self.handle_port.open("/" + self.module_name)

        # self.speech_port.open('/' + self.module_name + '/speech:i')
        self.text_port.open("/" + self.module_name + "/text:o")
        self.bookmark_port.open("/" + self.module_name + "/bookmark:i")

        print("\n\033[93m")
        info(" Recognizer info:")
        info(" Model: " + str(self.model))
        info(" Language: " + str(self.language))
        info(" Energy threshold: " + str(self.energy))
        info(" Pause threshold: " + str(self.pause))
        info(" Phrase time limit: " + str(self.phrase_time_limit))
        info(" Dynamic energy: " + str(self.dynamic_energy))
        info(" Use internal microphone: " + str(self.use_local_mic))
        print("\033[0m\n")

        # set the recognizer parameters
        self.r.energy_threshold = self.energy
        self.r.dynamic_energy_threshold = self.dynamic_energy
        self.r.pause_threshold = self.pause
        self.r.phrase_time_limit = self.phrase_time_limit

        return True

    def catch_bookmark(self):
        """read the bookmark port to know when the robot is speaking"""
        # connect to the bookmark port
        try:
            yarp.Network.connect('/acapelaSpeak/bookmark:o', '/speech2text/bookmark:i')
            #yarp.Network.connect("/keyboard:o", "/speech2text/bookmark:i")
        except Exception as e:
            error("Unable to connect to the bookmark port: " + str(e))
            return False

        while self.process:
            bookmark = self.bookmark_port.read(True)
            
            # we detect if the bookmark is switching from 1 to 0 or viceversa
            if bookmark is not None:
                bookmark = bookmark.toString()
                #bookmark = bookmark.get(0).asString()
                print("Bookmark: ", bookmark)
                # print("Listening: ", self.listening)
                if bookmark is not self.listening:
                    if bookmark == "1":
                        time.sleep(0.5)
                        # print in green
                        print("\033[92m" + "LISTENING" + "\033[0m")
                        self.listening = True
                        #when listening we set the energy threshold to the one set by the user
                        self.r.energy_threshold = self.energy
                    elif bookmark == "0":
                        # print in red
                        print("\033[91m" + "STOP LISTENING" + "\033[0m")
                        self.listening = False
                        # when not listening we set the energy threshold to a high value to avoid recording noise
                        self.r.energy_threshold = 100000 

        return True

    def updateModule(self):
        if self.process:
            self.acapela_synch = True
            if self.acapela_synch:
                # start a new thread to catch messages from the port, create a python thread
                self.thread = threading.Thread(target=self.catch_bookmark)
                self.thread.start()
            with self.microphone as source:
                # calibrate for 1 second
                self.r.adjust_for_ambient_noise(source, duration=1)
                print("Microphone calibrated")
                print("Say Something!")
                i = 0
                while self.process:
                    # listen for audio if robot is not speaking or we got an external signal (1) from on /speech2text/bookmark:i
                    if self.listening is True:
                        # record audio from microphone above energy threshold
                        audio = self.r.listen(source)
                        #print("AUDIO CHUNK RECORDED!")
                        try:
                            text = self.r.recognize_whisper(
                                audio, model=self.model, language=self.language
                            )
                            print("I heard:", text)
                            self.send_bottle(text)
                            if self.save_file:
                                with open(
                                    os.path.join(self.save_audio_dir, f"{i}.wav"),
                                    "wb",
                                ) as f:
                                    f.write(audio.get_wav_data())
                                i += 1
                        except sr.UnknownValueError:
                            print("Unable to recognize speech.")
                        except sr.RequestError as e:
                            print(f"Error: {e}")
                    else:
                        audio = 0
        return True

    def send_bottle(self, text):
        """send the recognized text to the output port"""
        event_bottle = yarp.Bottle()
        event_bottle.clear()
        event_bottle.addString(text)
        self.text_port.write(event_bottle)
        return

    def interruptModule(self):
        info("stopping the module")
        self.process = False
        self.handle_port.interrupt()
        self.speech_port.interrupt()
        self.text_port.interrupt()
        self.bookmark_port.interrupt()

        return True

    def close(self):
        info("closing the module")
        self.process = False
        # if self.thread is not None:
        #     # join the thread with a timeout
        #     self.thread.join(timeout=10)
        #     # check if the target thread is still running
        #     if self.thread.is_alive():
        #         # timeout expired, thread is still running
        #         print("thread is still running")
        #     else:
        #         print("thread is not running")
        #         # thread has terminated
        self.handle_port.close()
        self.speech_port.close()
        self.text_port.close()
        self.bookmark_port.close()

        return True

    def respond(self, command, reply):
        reply.clear()

        if command.get(0).asString() == "quit":
            # print in red
            print("\033[91m" + "quitting" + "\033[0m")
            self.close()
            reply.addString("quitting")
            return True

        elif command.get(0).asString() == "help":
            reply.addVocab(yarp.encode("many"))
            reply.addString("Speech recognition module commands are")

            reply.addString("help : Display this help message")
            reply.addString("start : Start the recording")
            reply.addString("stop : Stop the recording")
            reply.addString("quit : Quit the module")
            reply.addString("set lang : Change the language of the recognizer")
            reply.addString("set thr : Set the energy threshold for the recognizer")
            reply.addString("set pause : Set the pause threshold for the recognizer")
            reply.addString(
                "set dyn : Set the dynamic energy threshold for the recognizer"
            )
            reply.addString("set time : Set the phrase time limit for the recognizer")
            reply.addString("set save : Set whether to save the audio file clips")
            reply.addString(
                "set dir : Set the directory where to save the audio file clips"
            )

        elif command.get(0).asString() == "start":
            info("starting recording!\n")
            self.process = True
            reply.addString("rec started")

        elif command.get(0).asString() == "stop":
            info("stopping recording!\n")
            self.process = False
            reply.addString("rec stopped")

        elif command.get(0).asString() == "set":
            if command.get(1).asString() == "lang":
                lang_to_set = command.get(2).asString()
                self.language = lang_to_set
                reply.addString("set language to " + lang_to_set)
            elif command.get(1).asString() == "thr":
                thr_to_set = command.get(2).asInt32()
                self.energy = thr_to_set
                self.r.energy_threshold = thr_to_set
                reply.addString("set energy threshold to " + str(thr_to_set))
            elif command.get(1).asString() == "pause":
                pause_to_set = command.get(2).asFloat32()
                self.pause = pause_to_set
                self.r.pause_threshold = pause_to_set
                reply.addString("set pause threshold to " + str(pause_to_set))
            elif command.get(1).asString() == "dyn":
                dyn_to_set = command.get(2).asBool()
                self.dynamic_energy = dyn_to_set
                self.r.dynamic_energy_threshold = dyn_to_set
                reply.addString("set dynamic energy threshold to " + str(dyn_to_set))
            elif command.get(1).asString() == "time":
                time_to_set = command.get(2).asInt32()
                self.phrase_time_limit = time_to_set
                self.r.phrase_time_limit = time_to_set
                reply.addString("set phrase time limit to " + str(time_to_set))
            elif command.get(1).asString() == "save":
                save_to_set = command.get(2).asBool()
                self.save_file = save_to_set
                reply.addString("set save file to " + str(save_to_set))
            elif command.get(1).asString() == "dir":
                dir_to_set = command.get(2).asString()
                self.save_audio_dir = dir_to_set
                reply.addString("set save directory to " + str(dir_to_set))
            else:
                reply.addString("nack")
        else:
            reply.addString("Command not Recognized, try 'help' for a list of commands")

        return True

    def getPeriod(self):
        """
        Module refresh rate.

        Returns : The period of the module in seconds.
        """
        return 0.01


if __name__ == "__main__":
    # Initialise YARP
    if not yarp.Network.checkNetwork():
        info("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    Module = Speech2textModule()

    rf = yarp.ResourceFinder()
    rf.setVerbose(True)

    # For this module I prefer not to use a default context
    # rf.setDefaultContext('speech2text') # where to find .ini files for this application
    # rf.setDefaultConfigFile('speech2text.ini') # name of the default .ini file

    if rf.configure(sys.argv):
        Module.runModule(rf)
    sys.exit()
