import cv2
import os
import yarp


class Cube:

    def __init__(self, touch_port, action_port):

        self.touch_port = touch_port
        self.action_port = action_port

        print("initialization")

    def read(self):

        if self.touch_port.getInputCount():
            touch_bottle = self.touch_port.read(False)
        if self.action_port.getInputCount():
            action_bottle = self.action_port.read(False)
            action = action_bottle.get(0).asString()

    def process(self):

        print("process")

    def read_and_process(self):

        self.read()
        self.process()

        return

    def touch(self):

        print("touch")

        return
