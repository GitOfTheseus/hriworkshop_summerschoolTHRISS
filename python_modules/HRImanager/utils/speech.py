import yarp

class Speech:

    def __init__(self, text_in_port, LLM_out_port, LLM_in_port):

        self.text_in_port = text_in_port
        self.LLM_out_port = LLM_out_port
        self.LLM_in_port = LLM_in_port

        print("initialization of the speech")

    def listen(self):

        if self.text_in_port.getInputCount():
            speech_bottle = self.text_in_port.read(False)
            text = speech_bottle.get(0).asString()

            return text
