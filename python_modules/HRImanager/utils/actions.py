import yarp

class Action:

    def __init__(self, action_port, gaze_rpc_port, gaze_in_port):

        self.action_port = action_port
        self.gaze_rpc_port = gaze_rpc_port
        self.gaze_in_port = gaze_in_port

        print("initialization of the action")

    def execute(self, action):

        """
        Send action to interactionInterface
        :param String action:
        :return: None
        """
        if self.action_port.getOutputCount():
            action_bottle = yarp.Bottle()
            response = yarp.Bottle()
            action_bottle.clear()
            response.clear()
            action_bottle.addString("exe")
            action_bottle.addString(action)
            self.action_port.write(action_bottle, response)
            print("Sending to action port cmd: {}".format(action_bottle.toString()))
            for i in range(response.size()):
                print(f"Response is {response.get(i).toString()}")
                if response.get(i).asString() == "ok":
                    return True

        return False

    def look(self, position_3D):

        if self.gaze_rpc_port.getOutputCount():
            request_bottle = yarp.Bottle()
            info_bottle = yarp.Bottle()
            response_bottle = yarp.Bottle()

            request_bottle.clear()
            info_bottle.clear()
            response_bottle.clear()

            request_bottle.addString("look")
            request_bottle.addString("3D")
            info_bottle.addFloat64(position_3D[0])
            info_bottle.addFloat64(position_3D[1])
            info_bottle.addFloat64(position_3D[2])
            request_bottle.addList().copy(info_bottle)

            # possible good position look 3D (-1.5 -0.3 0)

            self.gaze_rpc_port.write(request_bottle, response_bottle)

            print(f"requesting the following command: {request_bottle.toString()}. Response: {response_bottle.toString()}")

    def check_gaze_motion_completed(self, target):

        if self.gaze_in_port.getInputCount():
            input_bottle = self.gaze_in_port.read(False)
            if input_bottle is not None:
                x = input_bottle.get(0).asFloat64()
                y = input_bottle.get(1).asFloat64()
                z = input_bottle.get(2).asFloat64()
                current = (x, y, z)
                movement_completed = all(abs(target[i] - current[i]) < 0.1 for i in range(len(current)))
                if movement_completed:
                    print("motion done")

                return movement_completed

        return False





