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

        return

    def localize(self):

        if self.obj_sim_port.getInputCount():
            input_bottle = self.obj_sim_port.read(False)
            if input_bottle is not None:
                object_class_dict = {}
                for i in range(input_bottle.size()):
                    pixel_coord = self.get_center(input_bottle.get(i).asList().get(2).asList().get(1).asList())
                    position_3D = self.get_3D_position(pixel_coord)
                    object_class_dict[input_bottle.get(i).asList().get(0).asList().get(1).asString()] = position_3D

                    # get 3D position with rpc port of iKinGaze e.g. get 3D mono ("left" 200 100 -0.5)

                return object_class_dict

        return

    def focus(self):

        if self.obj_sim_port.getInputCount():
            input_bottle = self.obj_sim_port.read(False)
            if input_bottle is not None:
                # objects in bottle are ordered according the confidence of recognition
                pixel_coord = self.get_center(input_bottle.get(0).asList().get(2).asList().get(1).asList())
                position_3D = self.get_3D_position(pixel_coord)

                return position_3D

        return

    def get_center(self, bounding_box):

        x = abs(bounding_box[2]-bounding_box[0])/2
        y = abs(bounding_box[3] - bounding_box[1]) / 2

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
            info_bottle.addInt64(pixel_coord[0])
            info_bottle.addInt64(pixel_coord[1])
            info_bottle.addFloat64(0.5) # distance
            request_bottle.addList().copy(info_bottle)

            self.gaze_port.write(request_bottle, response_bottle)

            x, y, z = (round(response_bottle.get(0).asFloat64,3), round(response_bottle.get(1).asFloat64,3),
                       round(response_bottle.get(2).asFloat64,3))

            return (x, y, z)

    def discretized_position(self, position_3D):

        y = position_3D[1]

        if y < -0.2:
            position = "left"
        elif y > 0.2:
            position = "right"
        else:   # (-0.2 <= y <= 0.2)
            position = "front"

        return position


    def point(self, position):

        if self.gaze_port.getOutputCount():
            action_bottle = yarp.Bottle()
            response = yarp.Bottle()
            action_bottle.clear()
            response.clear()
            action_bottle.addString("exe")
            action_bottle.addString(position)  #todo check that we have an action named as the position
            self.action_port.write(action_bottle, response)
            print("Sending to action port cmd: {}".format(action_bottle.toString()))



