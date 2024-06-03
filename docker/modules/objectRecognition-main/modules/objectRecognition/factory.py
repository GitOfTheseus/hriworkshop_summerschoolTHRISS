import supervision as sv
from ultralytics import YOLO
import numpy as np
import os

def info(msg):
    print("[INFO] {}".format(msg))

def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))


###########################################################
########### Abstract Factory Class ########################
###########################################################

# Class that has a standard init method common to all the factories (tasks)
class Factory:
    def __init__(self, annotator, task, dimension, nas, classes_to_detect, tracking, confidence_threshold, verbose):

        # Set the folder where the models are stored to /models
        current_script_folder = os.path.dirname(os.path.abspath(__file__))
        target_folder = os.path.join(current_script_folder, '../../models')
        os.chdir(target_folder)

        #variable initialization
        self.dimension = dimension
        self.task = task
        self.nas = nas
        self.confidence_threshold = confidence_threshold
        self.annotator = annotator
        self.tracking = tracking
        self.classes_to_detect = classes_to_detect
        self.verbose = verbose
        self.create_annotators()
        self.set_annotator(annotator)

        self.create_model(dimension, task, nas)

        if self.tracking:
            self.byte_tracker = sv.ByteTrack(track_thresh=self.confidence_threshold, track_buffer=120)

        
    def set_annotator(self, annotator):
        if annotator not in self.annotators_library.keys():
            error("The {} annotator is not supported by {} task, falling back to defaul annotator: {}".format(annotator, self.task, next(iter(self.annotators_library))))
            self.annotator = list(self.annotators_library.keys())[0] #we set the annotator to the first one in the supported list of annotators
            return False
        else:
            self.annotator = annotator
            return True

    def set_next_annotator(self):

        #get current index numeber in the list of keys
        current_index = list(self.annotators_library.keys()).index(self.annotator)
        #get the next index number
        next_index = (current_index + 1) % len(self.annotators_library)
        if next_index == 0:
            done = True
        else:
            #set the annotator to the next one
            self.annotator = list(self.annotators_library.keys())[next_index]
            done = False

        return done


    def print_info(self):
        info("Task: {}".format(self.task))
        info("Annotator: {}".format(self.annotator))
        info("Dimension: {}".format(self.dimension))
        info("NAS: {}".format(self.nas))
        info("Confidence threshold: {}".format(self.confidence_threshold))
        info("Tracking: {}".format(self.tracking))
        info("Classes to detect: {}".format(self.classes_to_detect))
        info("Verbose: {}".format(self.verbose))

###########################################################
#################### Detection Factory ####################
###########################################################

class DetectionFactory(Factory):

    def create_model(self, dimension, task, nas):
        if task == 'face_detection':
            self.model = YOLO('https://github.com/akanametov/yolov8-face/releases/download/v0.0.0/yolov8' + dimension + '-face.pt')
        else:
            if nas:
                self.model = models.get('yolo_nas_int8_'+ dimension, pretrained_weights="coco")
            else:
                self.model = YOLO('yolov8' + dimension + '.pt')

    def create_annotators(self):
        self.annotators_library = {
            "BoundingBox": sv.BoxAnnotator(),
            "BoxCorner": sv.BoxCornerAnnotator(),
            "BoxColor": sv.ColorAnnotator(),
            "Circle": sv.CircleAnnotator(),
            "Ellipse": sv.EllipseAnnotator(),
            "Label": sv.LabelAnnotator(text_position=sv.Position.TOP_CENTER),
            "Blur": sv.BlurAnnotator()
        }

    def predict(self, frame):
        if self.nas:
            result = list(self.model.predict(frame, conf=self.confidence_threshold))[0]
            detections = sv.Detections.from_yolo_nas(result)
        else:
            result = self.model(frame, verbose=self.verbose)[0] 
            detections = sv.Detections.from_ultralytics(result)
            if self.confidence_threshold:
                detections = detections[detections.confidence > self.confidence_threshold]

        # associate the labels to the detections
        labels = [
            result.names[class_id]
            for class_id
            in detections.class_id
        ]

        annotations = []
        if len(detections) == 0:
            annotated_image = frame
        else:
            # annotate
            if self.annotator != "Circle" and self.annotator != "Ellipse" and self.annotator != "Blur" and self.annotator != "BoxCorner" and self.annotator != "BoxColor":
                annotated_image = self.annotators_library[self.annotator].annotate(
                    scene=frame, detections=detections, labels=labels)
            else:
                annotated_image = self.annotators_library[self.annotator].annotate(
                    scene=frame, detections=detections)
            
            # for each detection
            for i in range(len(detections)):
                # create a dictionary
                detection = {}
                # add the class name
                detection['class'] = labels[i]
                # add the confidence
                detection['score'] = detections.confidence[i]
                # add the box coordinates
                detection['box'] = detections.xyxy[i].tolist()
                # append the dictionary to the list
                annotations.append(detection)
            
        return annotations, annotated_image


###########################################################
################# Segmentation Factory ####################
###########################################################
    
class SegmentationFactory(Factory):

    def create_model(self, dimension, task, nas):
        self.model = YOLO('yolov8' + dimension + '-seg.pt')
    
    def create_annotators(self):
        self.annotators_library = {
                "Mask": sv.MaskAnnotator(),
                "Label": sv.LabelAnnotator(text_position=sv.Position.CENTER),
                "Halo": sv.HaloAnnotator(),
                "Polygon": sv.PolygonAnnotator(),
                "Pixelate": sv.PixelateAnnotator()
            }
        
    def predict(self, frame):
        result = self.model(frame, verbose=self.verbose)[0]
        detections = sv.Detections.from_ultralytics(result)

        if self.confidence_threshold:
            detections = detections[detections.confidence > self.confidence_threshold]

        annotations = []
        if len(detections) == 0:
            annotated_image = frame

        else:
            # associate the labels to the detections
            labels = [
                result.names[class_id]
                for class_id
                in detections.class_id
            ]
            
            if self.annotator == "Label":
                annotated_image = self.annotators_library[self.annotator].annotate(scene=frame, detections=detections, labels=labels)
            else:
                annotated_image = self.annotators_library[self.annotator].annotate(scene=frame, detections=detections)

            # for each detection
            for i in range(len(detections)):
                # create a dictionary
                detection = {}
                # add the class name
                detection['class'] = labels[i]
                # add the confidence
                detection['score'] = detections.confidence[i]
                # add the box coordinates
                detection['box'] = detections.xyxy[i].tolist()
                # add the mask
                 # mask is too heavy to stream (>1080 values) on the port (>1080 values) 
                # leaving this here for future reference @Luca
                #detection['mask'] = detections.mask[i].tolist()

                # append the dictionary to the list
                annotations.append(detection)
            
        return annotations, annotated_image
        

###########################################################
############### Pose Detection Factory ####################
###########################################################


class PoseFactory(Factory):

    def create_model(self, dimension, task, nas):
        self.model =  YOLO('yolov8' + dimension + '-pose.pt')
        
    def set_annotator(self, annotator):
        #placeholder, we don't need annotators for pose detection
        return 
    
    def create_annotators(self):
        #placeholder, we don't need annotators for pose detection
        return
    
    def set_next_annotator(self):
        #placeholder, we don't need annotators for pose detection
        done = True
        return done

    def predict(self, frame):
        result = self.model(frame, verbose=self.verbose)[0]
        detections = sv.Detections.from_ultralytics(result)

        if self.confidence_threshold:
            detections = detections[detections.confidence > self.confidence_threshold]

        annotations = []

        if len(detections) == 0:
            annotated_image = frame

        else:
            annotated_image = result.plot()

            # for each detection
            for i in range(len(detections)):
                # create a dictionary
                detection = {}
                # add the class name
                detection['class'] = "person"
                # add the confidence
                detection['score'] = detections.confidence[i]
                # add the box coordinates
                detection['box'] = detections.xyxy[i].tolist()
                # add the keypoints
                detection['keypoints'] = result.keypoints[i].xy.cpu().numpy().flatten().tolist()
                # append the dictionary to the list
                annotations.append(detection)
            
        return annotations, annotated_image


# Map names to factories
FACTORY_MAP = {
    "detection": DetectionFactory,
    "face_detection": DetectionFactory,
    "segmentation": SegmentationFactory,
    "pose": PoseFactory
}

def factory_handler(annotator, task, dimension="n", nas=False, classes_to_detect=[], tracking=False, confidence_threshold=0.5, verbose=False):
    # Check if the task is valid
    if task not in FACTORY_MAP:
        error("Invalid task type: {}".format(task))
        raise ValueError("Invalid task type: {}".format(task))

    # Create the factory
    factory = FACTORY_MAP[task](annotator, task, dimension, nas, classes_to_detect, tracking, confidence_threshold, verbose)
    
    return factory

