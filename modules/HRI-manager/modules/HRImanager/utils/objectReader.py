import yarp

def warning(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))

class ObjectReader:

    def __init__(self, obj_in_port, gaze_port):

        self.obj_in_port = obj_in_port
        self.gaze_port = gaze_port

        print("initialization of the object reader")

    def read(self):

        if self.switch_detection_to_world():
            if self.obj_in_port.getInputCount():
                input_bottle = self.obj_in_port.read(False)
                if input_bottle is not None:
                    object_class_list = []
                    for i in range(input_bottle.size()):
                        object_class_list.append(input_bottle.get(i).asList().get(0).asList().get(1).asString())

                    return object_class_list

        return

    def localize(self):

        if self.switch_detection_to_simulation():
            if self.obj_in_port.getInputCount():
                input_bottle = self.obj_in_port.read(False)
                if input_bottle is not None:
                    object_class_dict = {}
                    for i in range(input_bottle.size()):
                        object_coord_list = []
                        for k in range(input_bottle.get(0).asList().get(2).asList().get(1).asList().size()):
                            object_coord_list.append(input_bottle.get(i).asList().get(2).asList().get(1).asList().get(k).asFloat32())
                        pixel_coord = self.get_center(object_coord_list)
                        position_3D = self.get_3D_position(pixel_coord)
                        object_class_dict[input_bottle.get(i).asList().get(0).asList().get(1).asString()] = position_3D

                        # get 3D position with rpc port of iKinGaze e.g. get 3D mono ("left" 200 100 -0.5)

                    return object_class_dict

        return

    def focus(self, object_category="banana"):

        if self.obj_in_port.getInputCount():
            input_bottle = self.obj_in_port.read(False)
            if input_bottle is not None:
                # objects in bottle are ordered according the confidence of recognition
                for k in range(input_bottle.size()):
                    if input_bottle.get(k).asList().get(0).asList().get(1).asString() == object_category:
                        object_coord_list = []
                        for i in range(input_bottle.get(0).asList().get(2).asList().get(1).asList().size()):
                            object_coord_list.append(input_bottle.get(k).asList().get(2).asList().get(1).asList().get(i).asFloat32())
                        pixel_coord = self.get_center(object_coord_list)
                        position_3D = self.get_3D_position(pixel_coord)

                        return position_3D

        return

    def get_center(self, bounding_box):

        x = abs(bounding_box[2] + bounding_box[0]) / 2
        y = abs(bounding_box[3] + bounding_box[1]) / 2

        return (x, y)

    def get_3D_position(self, pixel_coord):

        if self.gaze_port.getOutputCount():
            request_bottle = yarp.Bottle()
            info_bottle = yarp.Bottle()
            response_bottle = yarp.Bottle()

            request_bottle.clear()
            info_bottle.clear()
            response_bottle.clear()

            request_bottle.addString("get")
            request_bottle.addString("3D")
            request_bottle.addString("mono")
            info_bottle.addString("left")
            info_bottle.addFloat64(pixel_coord[0])
            info_bottle.addFloat64(pixel_coord[1])
            info_bottle.addFloat64(0.5) # distance was 0.5
            request_bottle.addList().copy(info_bottle)

            self.gaze_port.write(request_bottle, response_bottle)

            if response_bottle is not None:

                x, y, z = (round(response_bottle.get(1).asList().get(0).asFloat64(),3), round(response_bottle.get(1).asList().get(1).asFloat64(),3),
                       round(response_bottle.get(1).asList().get(2).asFloat64(),3))

                return (x, y, z)

    def discretized_position(self, position_3D):

        y = position_3D[1]

        if y < -0.1:
            position = "left"
        elif y > 0.1:
            position = "right"
        else:   # (-0.2 <= y <= 0.2)
            position = "front"

        return position

    def see_objects(self):

        object_class_list = self.read()

        objects_to_check = ["cup", "banana", "orange"]
        for o in object_class_list:
            if o in objects_to_check:
                return True

        return False

    def switch_detection_to_world(self):
        try:
            yarp.Network.disconnect('/icubSim/cam/left/rgbImage:o', '/objectRecognition/image:i')
            yarp.delay(1)
            yarp.Network.connect('/webcam', '/objectRecognition/image:i')
            yarp.delay(1)
            return True
        except Exception as e:
            warning("Unable to connect to the world port with gazebo: " + str(e))
            return False

    def switch_detection_to_simulation(self):
        try:
            yarp.Network.disconnect('/webcam', '/objectRecognition/image:i')
            yarp.delay(1)
            yarp.Network.connect('/icubSim/cam/left/rgbImage:o', '/objectRecognition/image:i')
            yarp.delay(1)
            return True
        except Exception as e:
            warning("Unable to connect to the world port with gazebo: " + str(e))
            return False



