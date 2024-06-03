
import yarp
import cv2
import sys

class WebcamModule(yarp.RFModule):
    def __init__(self):
        super().__init__()
        self.camera = cv2.VideoCapture(0)
        self.image = yarp.ImageRgb()
        # whether to resize the image or not
        self.resize = False

    def configure(self, rf):
        self.output_port = yarp.Port()
        self.output_port.open("/webcam/image:o")

        self.width = rf.check("width",
                                yarp.Value(self.camera.get(cv2.CAP_PROP_FRAME_WIDTH)),
                                "image width to stream").asInt32()
        
        self.height = rf.check("height",
                                yarp.Value(self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT)),
                                "image height to stream").asInt32()
        
        self.color = rf.check("color",
                                yarp.Value("rgb"),
                                "color code, either rgb or gray").asString()
        
        if self.width != self.camera.get(cv2.CAP_PROP_FRAME_WIDTH) or self.height != self.camera.get(cv2.CAP_PROP_FRAME_HEIGHT):
            self.resize = True
        
        print("[INFO] Ready to stream at port {} with resolution {}x{} in {} format".format(self.output_port.getName(),self.width, self.height, self.color))

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
        frame = self.camera.read()[1]
        if self.resize:
            frame = cv2.resize(frame, (self.width, self.height))
        #convert to
        if self.color == "gray":
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        elif self.color == "rgb":
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        elif self.color == "bgr":
            pass
        self.image.setExternal(frame , self.width, self.height)
        self.output_port.write(self.image)
        return True

if __name__ == "__main__":
    yarp.Network.init()
    module = WebcamModule()
    rf = yarp.ResourceFinder()
    rf.configure(sys.argv)
    module.runModule(rf)
    yarp.Network.fini()
