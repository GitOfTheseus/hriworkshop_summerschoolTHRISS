
import yarp
import cv2
import sys

class WebcamModule(yarp.RFModule):
    def __init__(self):
        super().__init__()
        self.camera = cv2.VideoCapture(0)
        self.width = int(self.camera.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.height = int(self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT))
        
        self.image = yarp.ImageRgb()


    def configure(self, rf):
        self.image.resize(self.width, self.height)
        self.output_port = yarp.Port()
        self.output_port.open("/webcam/image:o")

        return True

    def close(self):
        self.output_port.close()
        self.camera.release()
        yarp.Network.fini()
        return True

    def getPeriod(self):
        return 0.2

    def updateModule(self):
        if self.output_port.getOutputCount() == 0:
            return True
        self.frame = self.camera.read()[1]
        #convert to rgb
        self.frame = cv2.cvtColor(self.frame, cv2.COLOR_BGR2RGB)
        self.image.setExternal(self.frame, int(self.camera.get(cv2.CAP_PROP_FRAME_WIDTH)), int(self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT)))
        self.output_port.write(self.image)
        return True

if __name__ == "__main__":
    yarp.Network.init()
    module = WebcamModule()
    rf = yarp.ResourceFinder()
    rf.configure(sys.argv)
    module.runModule(rf)
    yarp.Network.fini()
