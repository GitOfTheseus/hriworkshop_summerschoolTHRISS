import numpy as np
import yarp
import math
import collections
import audioop
from speech_recognition import AudioSource

class YARP_Microphone(AudioSource):
    """
    Creates a new ``YARP_Microphone`` instance, which represents a physical microphone on the computer. Subclass of ``AudioSource``.


    The microphone audio is recorded in chunks of ``chunk_size`` samples, at a rate of ``sample_rate`` samples per second (Hertz). If not specified, the value of ``sample_rate`` is determined automatically from the yarp port.

    Higher ``sample_rate`` values result in better audio quality, but also more bandwidth (and therefore, slower recognition). Additionally, some CPUs, such as those in older Raspberry Pi models, can't keep up if this value is too high.

    Higher ``chunk_size`` values help avoid triggering on rapidly changing ambient noise, but also makes detection less sensitive. This value, generally, should be left at its default.
    """
    def __init__(self, writer_port="/audioRecorderWrapper/audio:o", reader_port="/speech2text/speech:i"):
        # initialize ports and variables
        self.writer_port = writer_port
        self.reader_port = reader_port
        self.audio = None
        self.stream = None

    def __enter__(self):
        #connect to the audio port and automatically read the first audio chunk
        self.stream = YARP_Microphone.MicrophoneStream(self.writer_port, self.reader_port)
        if self.stream is None:
            raise Exception("Error cerating Microphone stream")
        
        #read info about the stream
        self.SAMPLE_RATE = self.stream.sample_rate
        self.CHUNK = self.stream.samples
        self.SAMPLE_WIDTH = 2 # this is hard coded, can we read it from the port?

        # DEBUG ONLY
        print("SAMPLE_RATE: " + str(self.SAMPLE_RATE))
        print("CHUNK: " + str(self.CHUNK))
        print("SAMPLE_WIDTH: " + str(self.SAMPLE_WIDTH))
      
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.stream = None


    class MicrophoneStream(object):
        def __init__(self,  writer_port, reader_port):

            self.reader_port = reader_port
            self.writer_port = writer_port

            #open reading ports and read first chunk
            self.audio_in_port = yarp.BufferedPortSound()
            self.audio_in_port.open(reader_port)

            if not yarp.Network.connect(writer_port, reader_port):
                raise Exception("Error connecting to audio port")
            
            if self.read() is None:
                raise Exception("Error reading first chunk from audio port")

        def read(self, size=None):
            """
            read chunk from audio port, size argument is kept for compatibility with the original implementation
            """
            sound = self.audio_in_port.read(True)
            if sound:                
                self.channels = sound.getChannels()
                self.samples = sound.getSamples()
                self.sample_rate = sound.getFrequency()

                # DEBUG ONLY
                # print("channels: " + str(self.channels) + " samples: " + str(self.samples) + " sample_rate: " + str(self.sample_rate))

                chunk = np.zeros((self.channels, self.samples), dtype=np.int16)
                # build the numpy array
                for c in range(sound.getChannels()):
                    for i in range(sound.getSamples()):
                        chunk[c][i] = sound.get(i, c) 
                        # chunk[c][i] = sound.get(i, c) / 32768.0 #
                        # this was used to normalize the audio in therange [0,1] , but it is not needed since
                        # we handle audio with int16 values (hence the range is [-32768, 32767])
                        # I leave this for future reference
                #downsample to 16000 Hz
                # if self.sample_rate > 16000:
                #     print("downsampling from " + str(self.sample_rate) + " to 16000")
                #     chunk = chunk[:,::math.ceil(self.sample_rate/16000)]
                # else:
                chunk = chunk[0] # we only use the first channel TODO: handle multiple channels

            else:
                print("Error receiving audio from port")
                return None
            
            return chunk.squeeze().tobytes()

        def __exit__(self):
            # close ports
            try:
                yarp.Network.disconnect(self.writer_port, self.reader_port)
                self.audio_in_port.close()
            finally:
                self.audio_in_port = None
                self.sound = None