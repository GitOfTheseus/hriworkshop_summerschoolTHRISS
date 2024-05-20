import yarp


class Object:

    def __init__(self, read_port):

        self.read_port = read_port

        print("initialization")

    def read(self):

        if self.read_port.getInputCount():
            input_bottle = self.read_port.read(False)
            object_class = input_bottle.get(0).asString()

        return object_class

