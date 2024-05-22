import yarp

class Action:

    def __init__(self, action_port):

        self.action_port = action_port

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

        return True
