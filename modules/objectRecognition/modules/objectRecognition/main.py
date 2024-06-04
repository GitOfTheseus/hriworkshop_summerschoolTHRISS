import supervision as sv
from ultralytics import YOLO
#from super_gradients.training import models
from PIL import Image
import numpy as np
import cv2
import yarp
import sys
import os
import factory as f
import time

def info(msg):
    print("[INFO] {}".format(msg))

def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

def warning(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))

class ObjectRecognitionModule(yarp.RFModule):
    """
    Description:
        Object to read yarp image and localise and recognize objects

    Args:
        input_port  : input port of image
        output_port : output port for streaming recognized objects
        display_port: output port for image with recognized objects in bouding box
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

        # initialize variables
        self.timer = None

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)

        # Define vars to receive an image, NOTE that we convert to BGR
        self.input_port = yarp.BufferedPortImageRgb()
        
        # Create numpy array to receive the image and the YARP image wrapped around it
        self.input_img_array = None
        self.width_img = 640 #default, the size will be updated automatically
        self.height_img = 480 #default, the size will be updated automatically

        # Define vars for outputing image
        self.output_objects_port = yarp.Port()

        # Define vars for outputing image
        self.output_img_port = yarp.BufferedPortImageRgb()
        self.display_buf_array = None
        self.display_buf_image = yarp.ImageRgb()

    def configure(self, rf: yarp.ResourceFinder) -> bool:

        if rf.check('help') or rf.check('h'):
            print("object_recognition options:")
            print("\t--name (default object_recognition) module name")
            print("\t--task (default detection) task to perform: either detection/face_detection/pose/segmentation")
            print("\t--size (default n) size of the model: n/s/m/l/x")
            print("\t--annotator (default BoundingBox) annotator to use for the output image")
            print("\t--conf_threshold (default 0.5) confidence threshold for detection")
            print("\t--track (default False) enable tracking")
            print("\t--nas (default False) use NAS variant of YOLO")
            print("\t--classes (default None) list classes to recognize e.g. \"0 3 25\", by default all classes are recognized")
            print("\t--process (default True) enable automatic run")
            print("\t--demo (default False) enable demo mode")
            print("\t--help print this help")
            return False

        self.process = rf.check('process', yarp.Value(True), 'enable automatic run').asBool()

        self.module_name = rf.check("name",
                                    yarp.Value("objectRecognition"),
                                    "module name (string)").asString()
        
        task = rf.check('task', yarp.Value('detection'),
                                   'task to perform: either detection/face_detection/pose/segmentation').asString()

        dimension = rf.check('size', yarp.Value("n"),
                                  'size of the model: n/s/m/l/x').asString()
        
        annotator = rf.check('annotator', yarp.Value("BoundingBox"), #default BoundingBox
                            'annotator to use for the output image').asString()
        
        confidence_threshold = rf.check('conf_threshold', yarp.Value(0.5),
                                  'confidence threshold for detection (default:0.5)').asFloat32()
        
        tracking = rf.check('track', yarp.Value(False),'enable tracking').asBool()

        nas = rf.check('nas', yarp.Value(False), 'use NAS variant of YOLO').asBool()
        
        classes_to_detect = rf.check('classes', yarp.Value(""),
                                  'list classes to recognize e.g. "0 3 25", by default all classes are recognized').asString()
        
        self.DEMO_MODE = rf.check('demo', yarp.Value(False), 'enable demo mode').asBool()

        # initialize Detector annotator, task, dimension, nas, classes_to_detect=None, tracking=False, confidence_threshold=0.5
        self.Model = f.factory_handler(annotator, task, dimension, nas,
                                        classes_to_detect, tracking , confidence_threshold)

        #print model info
        self.Model.print_info()

        # Handle port
        self.handle_port.open('/' + self.module_name)

        # Input port for images
        self.input_port.open('/' + self.module_name + '/image:i')
        self.input_img_array = np.zeros((self.height_img, self.width_img, 3), dtype=np.uint8)
        
        # output ports for: (1) annotated_images (2) recognized_objects
        self.output_img_port.open('/' + self.module_name + '/annotated_image:o')
        self.output_objects_port.open('/' + self.module_name + '/objects:o')

        # format of the output image
        self.display_buf_image.resize(self.width_img, self.height_img)
        self.display_buf_array = np.zeros((self.height_img, self.width_img, 3), dtype=np.uint8)
        self.display_buf_image.setExternal(self.display_buf_array, self.width_img, self.height_img)

        info('Module initialization done, Running the model')
        self.DEBUG = False
        if self.DEBUG:
            if yarp.Network.connect("/webcam/image:o", "/objectRecognition/image:i"):
                Warning("LOCAL DEBUG: Connected to webcam")
            if yarp.Network.connect("/objectRecognition/annotated_image:o", "/yarpview/img:i"):
                Warning("LOCAL DEBUG: YARPVIEW connected to annotated image")

        return True
    
    def get_image_from_bottle(self, yarp_image):

        # Check image size, if differend adapt the size (this check takes 0.005 ms, we can afford it)
        if yarp_image.width() != self.width_img or yarp_image.height() != self.height_img:
            warning("imput image has different size from default 640x480, fallback to automatic size detection")
            self.width_img = yarp_image.width()
            self.height_img = yarp_image.height()
            self.input_img_array = np.zeros((self.height_img, self.width_img, 3), dtype=np.uint8)

        # Convert yarp image to numpy array
        yarp_image.setExternal(self.input_img_array, self.width_img, self.height_img)
        frame = np.frombuffer(self.input_img_array, dtype=np.uint8).reshape(
                (self.height_img, self.width_img, 3))
        
        #convert to rgb
        frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)

        return frame

    def updateModule(self):

        if self.process:
            # Read image from port
            message = self.input_port.read(False)

            if message is not None:

                # Read yarp image                
                frame = self.get_image_from_bottle(message)
    
                # PREDICTION AND ANNOTATION 
                self.objects, self.annotated_image = self.Model.predict(frame)

                if self.DEMO_MODE:
                    # we show all the annotators and tasks in demo mode
                    self.demo()

                # Write recognized objects if connected
                if self.output_objects_port.getOutputCount() or self.DEBUG:
                    self.write_objects()

                # Write annontated image if connected
                if self.output_img_port.getOutputCount():
                    self.write_annotated_image(self.annotated_image)

                # DEBUG: Show annotated image withou streaming it
                if self.DEBUG and self.annotated_image is not None:
                    #imshow using bgr format
                    cv2.imshow("window", self.annotated_image)
                    k = cv2.waitKey(1) & 0xff
                    
        return True
    
    def write_annotated_image(self, annotated_image):
        """
        Stream the annotated image on a yarp port
        """
        #convert annotated image to rgb format
        annotated_image = cv2.cvtColor(annotated_image, cv2.COLOR_BGR2RGB)
        # Stream annotated image
        self.display_buf_image = self.output_img_port.prepare()
        self.display_buf_image.resize(self.width_img, self.height_img)
        self.display_buf_image.setExternal(annotated_image.tobytes(), self.width_img, self.height_img)
        self.output_img_port.write()

    def dict2bottle(self, key, value):
        """
        Convert a dictionary to a yarp bottle
        :param key: key of the dictionary
        :param value: value of the dictionary
        :return: yarp bottle
        """

        bottle = yarp.Bottle()
        # add the key
        bottle.addString(key)
        # check the type of the value
        if isinstance(value, int):
            bottle.addInt16(value)
        elif isinstance(value, float):
            bottle.addFloat32(value)
        elif isinstance(value, str):
            bottle.addString(value)
        elif isinstance(value, list) or isinstance(value, np.ndarray):
            # if it is a list, add each element to the bottle
            bottle_list = yarp.Bottle()
            for element in value:
                if isinstance(element, int):
                    bottle_list.addInt16(element)
                elif isinstance(element, float):
                    bottle_list.addFloat32(element)
                elif isinstance(element, str):
                    bottle_list.addString(element)
            bottle.addList().read(bottle_list)
        return bottle

    def write_objects(self):
        """
        Stream the recognize objects name and coordiantes on a yarp port
        :param classes: list of classe names recognized
        :param keypoints: list of keypoints for each recognized objects
        :param boxes: list of boxe coordiantes for each recognized objects
        :param scores: list of score for each recognized objects
        """
        output_bottle = yarp.Bottle()
        obj_bottle = yarp.Bottle()
        output_bottle.clear()

        # iterate over the list of annotations and add them to the bottle
        if len(self.objects) > 0:
            for obj in self.objects:
                #add name
                obj_bottle.addList().read(self.dict2bottle("class", str(obj['class'])))
                #add score
                obj_bottle.addList().read(self.dict2bottle("score", float(obj['score'])))
                #add box
                obj_bottle.addList().read(self.dict2bottle("box", obj['box']))

                
                #try/excpet to avoid errors if the key is not present:
                #sort of a fix when switching from one task to another (happens only in demo mode)
                if self.Model.task == "pose":
                    try:
                        #add keypoints
                        obj_bottle.addList().read(self.dict2bottle("keypoints", obj['keypoints']))
                    except:
                        (error("keypoints not found"))

                # mask is too heavy to stream (>1080 values) on the port (>1080 values) 
                # leaving this here for future reference @Luca
                # elif self.Model.task == "segmentation":
                #     try:
                #         print(type(obj['mask']))
                #         obj_bottle.addList().read(self.dict2bottle("mask", obj['mask']))
                #     except:
                #         (error("mask not found"))

                output_bottle.addList().read(obj_bottle)
                obj_bottle.clear()

            #print content of the bottle in cyan
            print("\033[36m[INFO]: {}\033[00m".format(output_bottle.toString()))

            self.output_objects_port.write(output_bottle)

    def respond(self, command, reply):       
        reply.clear()

        if command.get(0).asString() == "quit":
            reply.addString("quitting")
            self.quit()
            return False

        elif command.get(0).asString() == "help":
            reply.addString("Object detector module command are:\n")
            reply.addString("set/get thr <double> -> to get/set the detection threshold \n")
            reply.addString("set/get annotator <string> -> to get/set the image annotator \n")

        elif command.get(0).asString() == "process":
            self.process = True if command.get(1).asString() == 'on' else False
            reply.addString("ok")


        elif command.get(0).asString() == "set":
            # set the confidence threshold
            if command.get(1).asString() == 'thr':
                if command.get(2).asFloat32() > 1.0 or command.get(2).asFloat32() < 0.0:
                    reply.addString("nack")
                else:
                    self.Model.confidence_threshold = command.get(2).asFloat32()
                    reply.addString("ok")

            # set the annotator
            elif command.get(1).asString() == 'annotator':
                annotator = command.get(2).asString()
                if self.Model.set_annotator(annotator):
                    reply.addString("ok")
                else:
                    reply.addString("nack")

            elif command.get(1).asString() == 'task':
                # we need to reinitialize the model
                task = command.get(2).asString()
                self.Model = f.factory_handler("default", task)
                reply.addString("ok")
            else:
                reply.addString("nack")

        elif command.get(0).asString() == "get":
            if command.get(1).asString() == 'thr':
                reply.addFloat64(self.Model.confidence_threshold)
            elif command.get(1).asString() == 'annotator':
                reply.addString(self.Model.annotator)
            else:
                reply.addString("nack")

        return True

    def getPeriod(self):
        """
           Module refresh rate.
           Returns : The period of the module in seconds.
        """
        return 0.001
    
    def interruptModule(self):
        print("stopping the module \n")
        self.handle_port.interrupt()
        self.input_port.interrupt()
        self.output_img_port.interrupt()
        self.output_objects_port.interrupt()
        
        return True

    def close(self):
        print("closing the module \n")
        self.handle_port.close()
        self.input_port.close()
        self.output_img_port.close()
        self.output_objects_port.close()

        return True

    def demo(self):
        """
        Demo mode: switch task and annotators to show all the possible combinations and debug all the behaviours
        """
        #start a timer and change annotator every 6 seconds, then change task and change annotator every 6 seconds ...
        if self.timer is None:
            self.timer = time.time()
        else:
            if time.time() - self.timer > 3:
                self.timer = time.time()
                done = self.Model.set_next_annotator()
                if not done:
                    print("switching to annotator: " + self.Model.annotator)
                else:
                    if self.Model.task == "detection":
                        next_task = "pose"
                    elif self.Model.task == "pose":
                        next_task = "segmentation"
                    elif self.Model.task == "segmentation":
                        next_task = "detection"
                    # we need to reinitialize the model, setting annotator to "Default" will force the first annotator available
                    self.Model = f.factory_handler("Default", next_task)
                    print("switching to task: " + next_task)

        #add to the annotated image the task and annotator
        cv2.putText(self.annotated_image, "Task: " + self.Model.task.upper(), (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        cv2.putText(self.annotated_image, "Annotator: " + self.Model.annotator, (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)


if __name__ == '__main__':

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        print("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    objectRecognitionModule = ObjectRecognitionModule()

    rf = yarp.ResourceFinder()
    rf.setVerbose(True)
    rf.setDefaultContext('objectRecognition')
    rf.setDefaultConfigFile('objectRecognition.ini')

    if rf.configure(sys.argv):
        objectRecognitionModule.runModule(rf)
    sys.exit()
