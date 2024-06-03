import speech_recognition as sr
import numpy as np

#load the speech recognizer and set the initial energy threshold and pause threshold
r = sr.Recognizer()
r.energy_threshold = 300
r.pause_threshold = 0.8
r.dynamic_energy_threshold = False

with sr.Microphone(sample_rate=16000) as source:
    print("Say something!")
    i = 0
    while True:
        #get and save audio to wav file
        # convert sorce to numpy array
        audio = np.frombuffer(source.stream.read(1024), dtype=np.int16)        
        print(audio.shape)

        # audio = r.listen(source)
        # i += 1
