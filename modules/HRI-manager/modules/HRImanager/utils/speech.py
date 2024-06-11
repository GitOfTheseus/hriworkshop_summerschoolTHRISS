import yarp

class Speech:

    def __init__(self, text_in_port, bookmark_out_port, LLM_out_port, LLM_in_port):

        self.text_in_port = text_in_port
        self.bookmark_out_port = bookmark_out_port
        self.LLM_out_port = LLM_out_port
        self.LLM_in_port = LLM_in_port

        print("initialization of the speech")

    def listen(self):

        if self.text_in_port.getInputCount():
            self.trigger_listener(1)
            yarp.delay(3)
            self.trigger_listener(0)
            speech_bottle = self.text_in_port.read(False)
            if speech_bottle is not None:
                text = speech_bottle.get(0).asString()

                return text

    def trigger_listener(self, bookmark):

        if self.bookmark_out_port.getOutputCount():
            write_bottle = yarp.Bottle()
            write_bottle.clear()
            write_bottle.addInt64(bookmark)
            self.bookmark_out_port.write(write_bottle)

    def reason(self, text):

        if self.LLM_out_port.getOutputCount() and self.LLM_in_port.getInputCount():

            write_bottle = yarp.Bottle()
            write_bottle.clear()
            write_bottle.addString(text)
            self.LLM_out_port.write(write_bottle)

            """
            the LLM is provided with this prompt: "you are a child who has to repeat the names of objects I show you. Just repeat one word."
            """

            read_bottle = self.LLM_in_port.read(True)
            if read_bottle is not None:
                category = read_bottle.get(0).asString()
                category = category.replace(" ", "")
                print(category)

                return category

            else:
                return ""




