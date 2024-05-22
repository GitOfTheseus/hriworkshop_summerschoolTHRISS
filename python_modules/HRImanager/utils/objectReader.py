import yarp


class ObjectReader:

    def __init__(self, read_port):

        self.read_port = read_port

        print("initialization of the object reader")

    def read(self):

        if self.read_port.getInputCount():
            input_bottle = self.read_port.read(False)
            if input_bottle is not None:
                object_class_list = []
                for i in range(input_bottle.size()):
                    object_class_list.append(input_bottle.get(i).asList().get(0).asList().get(1).asString())

                return object_class_list

        return []

    def find(self):

        if self.read_port.getInputCount():
            input_bottle = self.read_port.read(False)
            if input_bottle is not None:
                object_class_dict = {}
                for i in range(input_bottle.size()):
                    object_class_dict[input_bottle.get(i).asList().get(0).asList().get(1).asString()] = ""

                return object_class_list

        return []

