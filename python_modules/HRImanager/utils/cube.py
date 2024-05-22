import cv2
import os
import yarp


class Cube:

    def __init__(self, touch_port, event_port):

        self.touch_port = touch_port
        self.event_port = event_port

        print("initialization of the cube processor")

    def read(self):

        if self.touch_port.getInputCount():
            touch_bottle = self.touch_port.read(False)
        if self.event_port.getInputCount():
            event_bottle = self.event_port.read(False)
            event = event_bottle.get(0).asString()

    def process(self):

        print("process")

    def read_and_process(self):

        self.read()
        self.process()

        return

    def touch(self):

        print("touch")

        return
