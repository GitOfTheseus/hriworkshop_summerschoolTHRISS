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

    def reason(self, text):

        if self.LLM_out_port.getOutputCount() and self.LLM_in_port.getInputCount():

            write_bottle = yarp.Bottle()
            write_bottle.clear()
            write_bottle.addString(text)

            """
            the LLM is provided with this prompt: "you are a child who has to repeat the names of objects I show you. Just repeat one word."
            """

            read_bottle = self.LLM_in_port.read(True)
            category = read_bottle.get(0).asString()

            return category




