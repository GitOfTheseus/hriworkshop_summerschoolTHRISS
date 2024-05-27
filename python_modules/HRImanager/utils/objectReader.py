import yarp


class ObjectReader:

    def __init__(self, obj_webcam_port, obj_sim_port, gaze_port):

        self.obj_webcam_port = obj_webcam_port
        self.obj_sim_port = obj_sim_port
        self.gaze_port = gaze_port

        print("initialization of the object reader")

    def read(self):

        if self.obj_webcam_port.getInputCount():
            input_bottle = self.obj_webcam_port.read(False)
            if input_bottle is not None:
                object_class_list = []
                for i in range(input_bottle.size()):
                    object_class_list.append(input_bottle.get(i).asList().get(0).asList().get(1).asString())

                return object_class_list

        return []

    """
    def identify(self):

        if self.obj_sim_port.getInputCount():
            input_bottle = self.obj_sim_port.read(False)
            if input_bottle is not None:
                object_class_dict = {}
                for i in range(input_bottle.size()):
                    object_class_dict[input_bottle.get(i).asList().get(0).asList().get(1).asString()] = ""

                return object_class_list

        return []"""

    def localize(self):

        if self.gaze_port.getOutputCount():
            action_bottle = yarp.Bottle()
            response = yarp.Bottle()
            action_bottle.clear()
            response.clear()
            action_bottle.addString("exe")
            action_bottle.addString(action)
            self.action_port.write(action_bottle, response)
            print("Sending to action port cmd: {}".format(action_bottle.toString()))



