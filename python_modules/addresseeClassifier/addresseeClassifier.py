import csv
import yarp
import math
import os
import sys
import cv2
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import copy
import time
from datetime import datetime
import torch
from torchvision import transforms
from PIL import Image
import utils.util
from utils.body import Body
from modules_lightweight.pose import Pose
from utils.bodyLightweight import Body_Lightweight
from utils.classificationArchitecture import CNN_face, CNN_pose, LSTM, face, pose, fusion, self_att, GRU_att, Face_ViT
from utils.transformation import TransformedFace, TransformedPose
from utils.sequenceCreator import SequenceFace, SequencePose, UtteranceFace, UtterancePose
from utils.visualization import VisualPose, ModalityAttention
from utils.heatmap import HeatMap
from functools import partial
import collections
import argparse


def info(msg):
    print("[INFO] {}".format(msg))

def error(msg):
    print("\033[91m[ERROR] {}\033[00m".format(msg))

def warning(msg):
    print("\033[93m[WARNING] {}\033[00m".format(msg))


class AddresseeClassifier(yarp.RFModule):
    """
    Description:
        Class to recognize speaker from the audio
    Args:
        input_port  : Audio from remoteInterface
    """

    def __init__(self):
        yarp.RFModule.__init__(self)

        self.models_folder = os.path.abspath(os.path.join(__file__, "../../../models"))

        # handle port for the RFModule
        self.module_name = None
        self.handle_port = None

        # Define port
        self.image_in_port = yarp.BufferedPortImageRgb()
        self.image_out_port = yarp.BufferedPortImageRgb()
        self.image_out_port_attention_map = yarp.BufferedPortImageRgb()
        self.controller_input_port = yarp.BufferedPortBottle()
        self.addressee_output_port = yarp.BufferedPortBottle()
        self.rpc_server_port = yarp.RpcServer()

        # Image parameters
        self.display_buf_image_Full = yarp.ImageRgb()
        self.display_buf_array_Face = None
        self.display_buf_image_Face = yarp.ImageRgb()
        self.frame = yarp.ImageRgb()
        self.width_img = None
        self.height_img = None
        self.face_width = None
        self.face_height = None
        self.input_img_array = []
        self.frame_array = None
        self.attention_black = []

        self.original_size = None
        self.modality_attention_img_path = None
        self.modality_attention_filename = ""
        self.modalityAttention = None

        # identifying model
        self.classes = []
        self.pose_model = None
        self.pose_model_path = None
        self.body_estimation_lightweight = None
        self.classifier = None
        self.classifier_path = None

        self.n_seq = None
        self.seq_len = None
        self.num_classes = None
        self.speaker_pose = None

        # transformation concerns
        self.transformed_face = None
        self.transformed_pose = None
        self.sequence_face = None
        self.sequence_pose = None
        self.sequence_iterator = None
        self.sequenceFaces = None
        self.sequencePoses = None

        self.utteranceFaces = None
        self.utterancePoses = None

        self.interval = None
        self.sequence = None
        self.addressee_classifying = False
        self.end_utterance = False
        self.interaction_intention_estimation = None
        self.addressee_location = None
        self.coordinates_speaker = None

        self.all_predictions = None
        self.all_confidence = None
        self.final_prediction = None

        # current time
        self.previous_timestamp = None

        self.number = 0
        self.folderNumber = 1

        self.scale = None

    @property
    def device(self):
        return torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    def configure(self, rf):
        print('Running on device: {}'.format(self.device))

        # handle port for the RFModule
        self.handle_port = yarp.Port()
        self.attach(self.handle_port)

        self.sequence_pose = SequencePose(self.device)
        self.utterancePoses = UtterancePose()

        # Module parameters
        self.module_name = rf.check("name", yarp.Value("addresseeClassifier"), "module name (string)").asString()

        self.classifier = rf.check("classifier", yarp.Value(""), "classifier path (string)").asString()
        self.classifier_path = os.path.join(self.models_folder, self.classifier)

        self.pose_model = rf.check("pose_model", yarp.Value(), "Root path of the open pose model (string)").asString()
        self.pose_model_path = os.path.join(self.models_folder, self.pose_model)

        self.n_seq = rf.check("n_seq", yarp.Value(), "number of sequence LSTM (int)").asInt32()
        self.seq_len = rf.check("seq_len", yarp.Value(), "sequence length LSTM (int)").asInt32()
        self.num_classes = rf.check("num_classes", yarp.Value(), "number of classes (int)").asInt32()

        # image parameters
        self.width_img = rf.check("width_img", yarp.Value(), "width of the frame").asInt32()
        self.height_img = rf.check("height_img", yarp.Value(), "height of the frame").asInt32()
        self.face_width = rf.check("face_width", yarp.Value(), "width of the face").asInt32()
        self.face_height = rf.check("face_height", yarp.Value(), "height of the face").asInt32()
        self.original_size = self.face_height

        #self.modality_attention_img_path = "/usr/local/src/robot/cognitiveInteraction/xaddresseeestimation/python_modules/addresseeClassifier/tools"
        self.modality_attention_img_path = os.path.abspath(os.path.join(__file__, "../tools"))
        self.modality_attention_filename = "modalityAttention.jpg"
        self.modalityAttention = ModalityAttention(self.modality_attention_img_path, self.modality_attention_filename,
                                              self.original_size)

        self.transformed_pose = TransformedPose()

        self.sequence_iterator = 0
        self.sequenceFaces = self.sequence_face.get_empty(self.device)
        self.sequencePoses = self.sequence_pose.get_empty(self.device)

        self.addressee_location = ""
        self.coordinates_speaker = [self.width_img/2, self.height_img]

        if rf.check("classes"):
            classes_bottle = rf.find("classes").asList()
            for n in range(classes_bottle.size()):
                self.classes.append(classes_bottle.get(n).asString())

        # Create handle port to read message
        self.handle_port.open('/' + self.module_name)
        # create rpc port server
        self.rpc_server_port.open('/' + self.module_name + '/rpc')
        # Create input port to read face image
        self.image_in_port.open('/' + self.module_name + '/image:i')
        # Create output port write images
        self.image_out_port.open('/' + self.module_name + '/image:o')
        self.image_out_port_attention_map.open('/' + self.module_name + '/attentionMap:o')

        # Create output port to write addressee location
        self.addressee_output_port.open('/' + self.module_name + '/addressee:o')
        self.controller_input_port.open('/' + self.module_name + '/controller:i')

        self.input_img_array = np.zeros((self.height_img, self.width_img, 3), dtype=np.uint8).tobytes()
        self.speaker_pose = np.zeros(shape=(1, 18, 3))
        self.attention_black = np.ones((48, 48, 3), dtype=np.uint8) * 100
        self.body_estimation_lightweight = Body_Lightweight(self.pose_model_path, self.device)

        self.display_buf_image_Face.resize(self.attention_black.shape[1], self.attention_black.shape[0])
        self.display_buf_array_Face = np.zeros((self.attention_black.shape[1], self.attention_black.shape[0], 1), dtype=np.uint8)
        self.display_buf_image_Face.setExternal(self.display_buf_array_Face, self.attention_black.shape[1], self.attention_black.shape[0])

        self.interval = 0
        self.sequence = 0

        self.interaction_intention_estimation = False

        self.all_predictions = []
        self.all_confidence = []
        self.final_prediction = ""

        self.i = 0

        info("Initialization complete")

        # TODO maybe solve using a parameter..
        #yarp.Network.connect("/grabber", "/addresseeClassifier/image:i")  # external camera
        # yarp.Network.connect("/icub/camcalib/left/out", "/addresseeClassifier/image:i")  # iCub cameras
        #yarp.Network.connect("/addresseeClassifier/image:o", "/fullImage")
        #yarp.Network.connect("/addresseeClassifier/imageFace:o", "/faceImage")

        return True

    def interruptModule(self):
        print("[INFO] Stopping the module")

        self.handle_port.interrupt()
        self.image_in_port.interrupt()
        self.image_out_port.interrupt()
        self.image_out_port_attention_map.interrupt()
        self.addressee_output_port.interrupt()
        self.controller_input_port.interrupt()
        self.rpc_server_port.interrupt()

        return True

    def close(self):
        self.handle_port.close()
        self.image_in_port.close()
        self.image_out_port.close()
        self.image_out_port_attention_map.close()
        self.addressee_output_port.close()
        self.controller_input_port.close()
        self.rpc_server_port.close()

        return True

    def respond(self, command, reply):
        # Is the command recognized
        rec = False
        reply.clear()

        if command.get(0).asString() == "help":
            reply.addString("available commands are: \n "
                            "run: to start the classification \n"
                            "sus: to stop the classification \n"
                            "quit: to quit the module \n"
                            "help: to list the commands ")

        elif command.get(0).asString() == "run":
            self.addressee_classifying = True
            reply.addString("starting the classification")


        elif command.get(0).asString() == "stop":
            reply.addString("suspending the classification")

            self.end_utterance = True
            self.addressee_classifying = False
            self.interval += 1
            self.utteranceFaces.utterance_face = None
            self.utterancePoses.utterance_pose = None

        elif command.get(0).asString() == "quit":
            reply.addString("quitting")
            return False

        else:
            reply.addString("Wrong command. \n"
                            "Write help to see options. Otherwise quit, if you want to quit the module.")

        command.clear()

        return True

    def getPeriod(self):
        """
           Module refresh rate.

           Returns : The period of the module in seconds.
        """
        return 0.08

    def updateModule(self):
        """
        if self.rpc_server_port.getInputCount():
            #### PART RESPONSIBLE OF THE CLASSIFICATION IF BOTTLE IN IS START
            bottle_in = yarp.Bottle()
            bottle_out = yarp.Bottle()
            self.rpc_server_port.read(bottle_in, True)
            print("Readed: ", bottle_in.toString())
            msg = "Message " + bottle_in.toString() + " received in cycle: "
            if msg == 'start':
                classification = True
            bottle_out.addString(msg)
            self.rpc_server_port.reply(bottle_out)
            """

        #try:
        #self.receive_controller_info()  # todo: only if respond causes problems


        if self.image_in_port.getInputCount():
            # reading image from yarp port
            input_yarp_image = self.image_in_port.read(False)
            
            # clock here to save timestampprint("here")
            if input_yarp_image is not None:

                self.frame = self.read_image(input_yarp_image)
                
                """# function to print time passing and check if the code is running every 80 ms
                self.print_time_passing()"""

                # extracting the image with joints as img_processed
                # getting the pose_vector containing the values of X,Y and conf of the joints
                img_processed, pose_vector = self.extract_pose_lightweight()  # model from
                # https://github.com/Daniil-Osokin/lightweight-human-pose-estimation.pytorch/tree/master

                if self.addressee_classifying:

                    if np.shape(pose_vector)[0] != 0:  # check if at least one person is detected
                        # sorting the poses in the pose vector
                        pose_vector_sorted = utils.util.sort_poses(pose_vector)

                        # function to select the speaker among the people detected
                        self.speaker_pose, self.coordinates_speaker = utils.util.find_speaker(pose_vector_sorted,
                                                                                              self.width_img,
                                                                                              self.height_img)

                        # crop the face of the speaker and show it in the viewer
                        resized_face = self.crop_speaker_face(self.speaker_pose)

                        # pose visualization
                        img_pose_speaker = self.visualize_pose_speaker()  # still to crop with get_center

                        # transforming the coordinates of the speaker's pose from pixel to [-1, 1]
                        speaker_transformed = utils.util.transform_pixel_to_point(self.speaker_pose, self.width_img,
                                                                                  self.height_img)

                        # transforming speaker pose to tensor
                        pose_tensor = torch.from_numpy(speaker_transformed)
                        # transform face to tensor
                        face_tensor = self.transformed_face(resized_face)


                        # creating sequences of 10 tensors
                        self.sequenceFaces = self.sequence_face(self.sequence_iterator, face_tensor)
                        self.sequencePoses = self.sequence_pose(self.sequence_iterator, pose_tensor)
                        self.sequence_iterator += 1

                        self.utteranceFaces.add_element(face_tensor)
                        self.utterancePoses.add_element(pose_tensor)

                        if version == 'att-3' or version == 'att-combined':
                            pose_tensor = pose_tensor.to(torch.float32)
                            face_importance, pose_importance = self.compute_importance(face_tensor.unsqueeze(0), pose_tensor.unsqueeze(0))
                            if version == 'att-combined':
                                img_original, img_attention, img_overlap = self.compute_attention_map(face_tensor.unsqueeze(0))
                                img_original, attention_map, img_overlap = self.transform_images_for_yarp(img_original, img_attention, img_overlap)

                                if self.image_out_port_attention_map.getOutputCount():
                                    self.show_attention_map(attention_map)

                        else:
                            face_importance = 0.5
                            pose_importance = 0.5

                        if self.sequence_iterator % 10 == 0:
                            # classifying the sequences to get the prediction of the addressee's location
                            prediction, confidence = self.classify_addressee(self.sequenceFaces, self.sequencePoses)

                            self.addressee_location = self.classes[prediction]
                            self.all_confidence.append(confidence)
                            self.all_predictions.append(prediction)
                            self.get_sequences_empty()
                            self.combine_sequences_predictions()
                            if version == 'ijcnn':
                                self.send_addressee_location(self.final_prediction, confidence)
                            self.sequence += 1

                            #todo see below

                        # pose and face visualization
                        img = self.modalityAttention.visualize(face_importance, pose_importance, resized_face,
                                                               img_pose_speaker)
                        if self.image_out_port.getOutputCount():
                            self.write_yarp_image(img)

                    else:  # the list of pose_vector is empty (no people detected)
                        self.addressee_location = "no people detected"

                else:  # self.addressee_classifying is False

                    if self.image_out_port_attention_map.getOutputCount():
                        self.show_attention_map(self.attention_black)
                    img = self.modalityAttention.empty()
                    if self.image_out_port.getOutputCount():
                        self.write_yarp_image(img)

                    if self.end_utterance:
                        self.classify_addressee(self.sequenceFaces, self.sequencePoses, True)
                        self.end_utterance = False

                    self.addressee_location = "non-active estimation"
                    self.get_sequences_empty()
                    self.all_confidence = []
                    self.all_predictions = []

                self.print_info_on_img(img_processed)

        else:

            info("no images from yarp port")

        #except:
        #    print("Error")
        #    pass

        return True

    def read_image(self, yarp_image):

        # Check image size, if differend adapt the size (this check takes 0.005 ms, we can afford it)
        if yarp_image.width() != self.width_img or yarp_image.height() != self.height_img:
            warning("input image has different size from default 640x480, fallback to automatic size detection")
            print("yarp image sizes are {}x{}, while module processes {}x{}".format(yarp_image.width(), yarp_image.height(), self.width_img, self.height_img))
            self.width_img = yarp_image.width()
            self.height_img = yarp_image.height()
            self.input_img_array = np.zeros((self.height_img, self.width_img, 3), dtype=np.uint8)

        yarp_image.setExternal(self.input_img_array, self.width_img, self.height_img)
        frame = np.frombuffer(self.input_img_array, dtype=np.uint8).reshape(
            (self.height_img, self.width_img, 3)).copy()

        return frame

    def extract_pose_lightweight(self):

        img, pose_vector = self.body_estimation_lightweight(self.frame)

        return img, pose_vector

    def visualize_pose_speaker(self):

        img_pose_speaker = np.zeros((self.height_img, self.width_img, 3), dtype='uint8')
        visualPose = VisualPose(self.speaker_pose[0], img_pose_speaker, self.original_size)
        visualPose.shift()
        visualPose.draw()
        squared_img_pose = visualPose.crop()

        #if self.image_out_port_Full.getOutputCount():
        #    self.write_yarp_image_Full(squared_img_pose)

        return squared_img_pose

    def crop_speaker_face(self, speaker):

        # initialize face image as a black image
        resized_face = np.zeros((self.face_width, self.face_height, 3), dtype=np.uint8)
        # specifying the speaker to crop his face, once the face is detected
        face_detected, face_coordinates = self.get_face_coordinates(speaker)
        if face_detected:
            cropped_face = self.frame[face_coordinates[0]:face_coordinates[1],
                           face_coordinates[2]:face_coordinates[3]]

            resized_face = cv2.resize(cropped_face, (self.face_width, self.face_height), interpolation=cv2.INTER_LINEAR)

        return resized_face

    def write_yarp_image_Full(self, image_processed):
        """
        Handle function to stream the recognize faces with their bounding rectangles
        :param img_array:
        :return:
        """

        self.display_buf_image_Full = self.image_out_port.prepare()
        self.display_buf_image_Full.resize(self.original_size, self.original_size)
        self.display_buf_image_Full.setExternal(image_processed.tobytes(), image_processed.shape[1], image_processed.shape[0])
        self.image_out_port.write()

    def show_attention_map(self, attention_face):
        """
        Handle function to stream the recognize faces with their bounding rectangles
        :param img_array:
        :return:
        """
        display_buf_image = self.image_out_port_attention_map.prepare()
        #self.display_buf_image_Face.resize(attention_face.shape[1], attention_face.shape[0])
        display_buf_image.setExternal(attention_face.tobytes(), attention_face.shape[1], attention_face.shape[0])
        self.image_out_port_attention_map.write()

        return

    def write_yarp_image(self, img):
        """
        Handle function to stream the recognize faces with their bounding rectangles
        :param img_array:
        :return:
        """
        display_buf_image = self.image_out_port.prepare()
        display_buf_image.setExternal(img.tobytes(), img.shape[1], img.shape[0])
        self.image_out_port.write()

        return


    def get_face_coordinates(self, pose):

        face_detected = False
        face_coordinates = [0, 0, 0, 0]
        center_face = [int(pose[0][0][0]), int(pose[0][0][1])]
        base_neck = [int(pose[0][1][0]), int(pose[0][1][1])]
        left_ear = [int(pose[0][16][0]), int(pose[0][16][1])]
        right_ear = [int(pose[0][17][0]), int(pose[0][17][1])]

        # if face was detected
        if pose[0][0][2] != 0:

            face_detected = True

            dist1 = int(math.hypot(center_face[0] - base_neck[0], center_face[1] - base_neck[1]) * 3 / 5)
            dist2 = int(math.hypot(center_face[0] - left_ear[0], center_face[1] - left_ear[1]))
            dist3 = int(math.hypot(center_face[0] - right_ear[0], center_face[1] - right_ear[1]))

            if base_neck[0] == 0:
                dist1 = 0
            if left_ear[0] == 0:
                dist2 = 0
            if right_ear[0] == 0:
                dist3 = 0

            ray = max(dist1, dist2, dist3)
            if ray == 0:
                face_detected = False
            else:
                ray = max(ray, 15)

            over_edge = int(center_face[1] - ray)
            left_edge = center_face[0] - ray
            right_edge = center_face[0] + ray
            bottom_edge = center_face[1] + ray

            if over_edge < 0:
                bottom_edge -= over_edge
                over_edge = 0
            if left_edge < 0:
                right_edge -= left_edge
                left_edge = 0
            if bottom_edge > self.height_img:
                over_edge -= bottom_edge - self.height_img
                bottom_edge = self.height_img
            if right_edge > self.width_img:
                left_edge -= right_edge - self.width_img
                right_edge = self.width_img

            face_coordinates = [over_edge, bottom_edge, left_edge, right_edge]

        return face_detected, face_coordinates

# from the sequences of Faces and Poses we can classify where the addressee is
    def classify_addressee(self, faces, poses, write_msg=False):
        raise NotImplementedError()

    def print_time_passing(self):
        # getting the time after reading each frame
        time_get_frame = time.time()
        time_get_frame_ms = time_get_frame * 1000

        # getting the difference timing between consecutive frames
        if self.previous_timestamp is not None:
            difference_timing = int(time_get_frame_ms) - int(self.previous_timestamp)
            print("starting Time", time_get_frame_ms)
            print("Ending Time", self.previous_timestamp)
            # print("difference in timing", difference_timing)
        self.previous_timestamp = time_get_frame_ms

        return

    def print_info_on_img(self, img_processed):

        cv2.putText(img_processed, self.addressee_location,
                    (int(self.coordinates_speaker[0] - 20), int(self.coordinates_speaker[1] - 20)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 0, 255), 2, 2)

        return

    """def receive_controller_info(self):

        if self.controller_input_port.getInputCount():
            # reading image from yarp port
            input_bottle = self.controller_input_port.read(False)
            # clock here to save timestamp
            if input_bottle is not None:
                cmd = input_bottle.get(0).asString()
                if cmd == "run":
                    info("starting the classification")
                    self.addressee_classifying = True
                elif cmd == "sus":
                    info("suspending the classification")
                    self.classify_addressee(self.utteranceFaces.utterance_face, self.utterancePoses.utterance_pose,
                                            True)
                    self.addressee_classifying = False
                    self.interval += 1
                    self.utteranceFaces.utterance_face = None
                    self.utterancePoses.utterance_pose = None

        return"""


    def send_addressee_location(self, predicted_direction, confidence, sentence=""):

        bottle = self.addressee_output_port.prepare()
        bottle.clear()
        bottle.addString(predicted_direction)
        bottle.addFloat32(confidence)
        bottle.addString(sentence)

        print("Sending info about addressee location: ", bottle.toString())
        self.addressee_output_port.write()

        return

    def get_sequences_empty(self):

        self.sequenceFaces = self.sequence_face.get_empty(self.device)
        self.sequencePoses = self.sequence_pose.get_empty(self.device)
        self.sequence_iterator = 0

        return

    def combine_sequences_predictions(self):
        interval_results = np.zeros(3)
        for p, prediction in enumerate(self.all_predictions):
            interval_results[prediction] = interval_results[prediction] + self.all_confidence[p]

        self.final_prediction = self.classes[np.argmax(interval_results)]

        return


class AddresseeClassifierAtt3(AddresseeClassifier):
    def __init__(self):
        # init common params
        super(AddresseeClassifierAtt3, self).__init__()

        self.face_model = None
        self.pose_model = None
        self.att_model = None
        self.fusion_model = None

        self.classifier_path = None
        self.face_file = None
        self.pose_file = None
        self.att_file = None
        self.fusion_file = None

        self.face_size = None
        self.face_act = None
        self.face_hid = None
        self.face_out = None
        self.face_drop = None

        self.pose_act = None
        self.pose_hid = None
        self.pose_out = None

        self.att_dim_inner = None
        self.att_dim_feature = None
        self.att_dim_k = None
        self.att_act = None

        self.fusion_act = None
        self.fusion_inp = None
        self.fusion_hid = None
        self.fusion_out = None
        self.fusion_drop = None

    def configure(self, rf):
        self.transformed_face = TransformedFace(scale=False)
        self.sequence_face = SequenceFace(self.device, False)
        self.utteranceFaces = UtteranceFace()

        #self.display_buf_image.resize(self.width_img, self.height_img)


        super(AddresseeClassifierAtt3, self).configure(rf)

        self.face_file = rf.check("face", yarp.Value(""), "module file (string)").asString()
        self.pose_file = rf.check("pose", yarp.Value(""), "module file (string)").asString()
        self.att_file = rf.check("att", yarp.Value(""), "module file (string)").asString()
        self.fusion_file = rf.check("fusion", yarp.Value(""), "module file (string)").asString()
        self.face_size = rf.check("face_size", yarp.Value(), "size of the convolutional network (string)").asString()
        self.face_act = rf.check("face_act", yarp.Value(),
                                 "activation function of the face network (string)").asString()
        self.face_hid = rf.check("face_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.face_out = rf.check("face_out", yarp.Value(), "number of output neurons (int)").asInt32()
        self.face_drop = rf.check("face_drop", yarp.Value(),
                                  "dropout probability for the face network (float)").asFloat32()

        self.pose_act = rf.check("pose_act", yarp.Value(),
                                 "activation function of the pose network (string)").asString()
        self.pose_hid = rf.check("pose_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.pose_out = rf.check("pose_out", yarp.Value(), "number of output neurons (int)").asInt32()

        self.att_dim_inner = rf.check("att_dim_inner", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_dim_feature = rf.check("att_dim_feature", yarp.Value(),
                                        "number of neurons att network (int)").asInt32()
        self.att_dim_k = rf.check("att_dim_k", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_act = rf.check("att_act", yarp.Value(), "activation function of the att network (string)").asString()

        self.fusion_act = rf.check("fusion_act", yarp.Value(),
                                   "activation function of the GRU network (string)").asString()
        self.fusion_inp = rf.check("fusion_inp", yarp.Value(), "input size of GRU network (int)").asInt32()
        self.fusion_hid = rf.check("fusion_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.fusion_out = rf.check("fusion_out", yarp.Value(), "number of output neurons (int)").asInt32()
        self.fusion_drop = rf.check("fusion_drop", yarp.Value(),
                                    "dropout probability for the GRU network (float)").asFloat32()

        self.face_model = face(os.path.join(self.classifier_path, self.face_file), self.face_size, self.face_act,
                               self.face_hid, self.face_out, self.face_drop, self.device)
        self.pose_model = pose(os.path.join(self.classifier_path, self.pose_file), self.pose_act, self.pose_hid,
                               self.pose_out, self.device)
        self.att_model = self_att(os.path.join(self.classifier_path, self.att_file), self.att_dim_inner,
                                  self.att_dim_feature, self.att_dim_k, self.att_act, self.device)
        self.fusion_model = fusion(os.path.join(self.classifier_path, self.fusion_file), self.fusion_act,
                                   self.fusion_inp, self.fusion_hid, self.fusion_out, self.seq_len, self.n_seq,
                                   self.num_classes, self.fusion_drop, self.device)

        return True

    def classify_addressee(self, faces, poses, send_msg=False):

        with torch.no_grad():
            # making sure we are running the sequences with cuda
            faces = faces.to(self.device)
            poses = poses.to(self.device)

            # getting the embedding by passing the sequences to the CNN layers
            face_embedding = self.face_model(faces)
            pose_embedding = self.pose_model(poses)
            merged_embedding = self.att_model(face_embedding, pose_embedding)
            output, current_batch = self.fusion_model(merged_embedding)

            confidence, predictions = torch.max(output, 1)

            #classes = {0: 'robot', 1: 'left', 2: 'right'}
            prob = np.exp(confidence.detach().cpu().numpy())  # exp due to log_softmax
            predictions_np = predictions.detach().cpu().numpy()

            probability = f'({float(prob) * 100:2.2f} %)'
            predicted_direction = self.classes[int(predictions_np)]

            _, importances = self.get_output_and_importance(self.att_model.model, face_embedding, pose_embedding)

            sentence = ""

            if send_msg:
                if abs(importances[0] - importances[1]) < 0.10:
                    sentence = "Your face weighted more than your body-pose in my estimation"
                elif importances[0] > importances[1]:
                    sentence = "Your face weighted more than your body-pose in my estimation"
                elif importances[1] > importances[0]:
                    sentence = "Your body-pose weighted more than your face in my estimation"

            self.send_addressee_location(predicted_direction, round(np.exp(confidence.item()), 2), sentence)

        return predictions, round(np.exp(confidence.item()), 2)

    def compute_importance(self, face, pose):

        with torch.no_grad():
            # making sure we are running the sequences with cuda
            face = face.to(self.device)
            pose = pose.to(self.device)

            # getting the embedding by passing the sequences to the CNN layers
            face_embedding = self.face_model(face)
            pose_embedding = self.pose_model(pose)

            _, importances = self.get_output_and_importance(self.att_model.model, face_embedding, pose_embedding)

        return importances[0][0], importances[0][1]

    @staticmethod
    def get_output_and_importance(model, face, pose):
        def save_activation(name_l, mod, inp, out_l):
            activations[name_l] = out_l

        for name, m in model.named_modules():
            m.register_forward_hook(partial(save_activation, name))

        activations = collections.defaultdict(list)
        out = model(face, pose)

        # activations = {itm: outputs for itm, outputs in activations.items()}  # probably not needed
        feature_importances = activations['feature_importance']

        return out, feature_importances



class AddresseeClassifierAtt4(AddresseeClassifier):
    def __init__(self):
        # init common params
        super(AddresseeClassifierAtt4, self).__init__()

        self.face_model = None
        self.pose_model = None
        self.att_model = None

        self.classifier_path = None
        self.face_file = None
        self.pose_file = None
        self.att_file = None

        self.face_size = None
        self.face_act = None
        self.face_hid = None
        self.face_out = None
        self.face_drop = None

        self.pose_act = None
        self.pose_hid = None
        self.pose_out = None

        self.att_dim_v = None
        self.att_dim_kq = None
        self.att_act = None
        self.att_embed_kv = None
        self.att_embed_q = None

    def configure(self, rf):
        self.transformed_face = TransformedFace(scale=False)
        self.sequence_face = SequenceFace(self.device, False)
        self.utteranceFaces = UtteranceFace()

        super(AddresseeClassifierAtt4, self).configure(rf)

        self.face_file = rf.check("face", yarp.Value(""), "module file (string)").asString()
        self.pose_file = rf.check("pose", yarp.Value(""), "module file (string)").asString()
        self.att_file = rf.check("att", yarp.Value(""), "module file (string)").asString()
        self.face_size = rf.check("face_size", yarp.Value(), "size of the convolutional network (string)").asString()
        self.face_act = rf.check("face_act", yarp.Value(),
                                 "activation function of the face network (string)").asString()
        self.face_hid = rf.check("face_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.face_out = rf.check("face_out", yarp.Value(), "number of output neurons (int)").asInt32()
        self.face_drop = rf.check("face_drop", yarp.Value(),
                                  "dropout probability for the face network (float)").asFloat32()

        self.pose_act = rf.check("pose_act", yarp.Value(),
                                 "activation function of the pose network (string)").asString()
        self.pose_hid = rf.check("pose_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.pose_out = rf.check("pose_out", yarp.Value(), "number of output neurons (int)").asInt32()

        self.att_dim_v = rf.check("att_dim_v", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_dim_kq = rf.check("att_dim_kq", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_act = rf.check("att_act", yarp.Value(), "activation function of the att network (string)").asString()

        self.att_embed_kv = rf.check("att_embed_kv", yarp.Value(), "whether to use kv embedding").asBool()
        self.att_embed_q = rf.check("att_embed_q", yarp.Value(), "whether to use q embedding").asBool()

        self.face_model = face(os.path.join(self.classifier_path, self.face_file), self.face_size, self.face_act,
                               self.face_hid, self.face_out, self.face_drop, self.device)
        self.pose_model = pose(os.path.join(self.classifier_path, self.pose_file), self.pose_act, self.pose_hid,
                               self.pose_out, self.device)
        self.att_model = GRU_att(os.path.join(self.classifier_path, self.att_file), self.seq_len, self.n_seq,
                                 self.att_act, self.num_classes, self.face_out, self.pose_out, self.att_dim_kq,
                                 self.att_dim_v, self.att_embed_kv, self.att_embed_q, self.device)

        return True

    def classify_addressee(self, faces, poses, send_msg=False):
        if faces is None:
            #print("There were no people detected!")
            return
        with torch.no_grad():
            # making sure we are running the sequences with cuda
            faces = faces.to(self.device)
            poses = poses.to(self.device)

            face_tensor = self.face_model(faces)
            pose_tensor = self.pose_model(poses)

            output, current_batch = self.att_model(face_tensor, pose_tensor, faces.shape[0])

            confidence, predictions = torch.max(output, 1)

            #classes = {0: 'robot', 1: 'left', 2: 'right'}
            prob = np.exp(confidence.detach().cpu().numpy())  # exp due to log_softmax
            predictions_np = predictions.detach().cpu().numpy()

            probability = f'({float(prob) * 100:2.2f} %)'
            predicted_direction = self.classes[int(predictions_np)]
            sentence = ""

            if send_msg:
                explanation = self.extract_explanations(face_tensor, pose_tensor, faces.shape[0])
                if explanation == '':
                    if int(predictions_np) == 0:
                        sentence = 'Based on your non-verbal behavior, I think you are talking to me'
                    else:
                        sentence = (f'Based on your non-verbal behavior, I guess you are talking to someone to my '
                                    f'{self.classes[int(predictions_np)]}')
                else:
                    if int(predictions_np) == 0:
                        sentence = (f'Based on you non-verbal behavior at the {explanation} of the interaction, '
                                    f'I think you are talking to me')
                    else:
                        sentence = (
                            f'Based on you non-verbal behavior at the {explanation} of the interaction, I guess you '
                            f'are talking to someone to my {self.classes[int(predictions_np)]}')
                print("\n\nEND OF THE ESTIMATION\n\n")

            self.send_addressee_location(predicted_direction, round(np.exp(confidence.item()), 2), sentence)

        return predictions, round(np.exp(confidence.item()), 2)

    def extract_explanations(self, face_vector, pose_vector, length):
        _, importance = self.get_output_and_importance(self.att_model.model, face_vector, pose_vector, length)
        importance = importance.detach().cpu().numpy()

        explanations = self.get_sentence(importance)

        return explanations

    @staticmethod
    def get_sentence(arr, threshold=0.03, n_window=None):
        seq_len = arr.shape[0]
        if n_window is None:
            n_window = seq_len // 3

        assert n_window <= seq_len

        actual = 0
        explanations = []

        while actual + n_window < seq_len:
            actual += 1
            current_weight = np.sum(arr[actual:actual + n_window])

            if current_weight > n_window / seq_len + threshold:
                center = (2 * actual + n_window) // 2
                if center <= n_window:                                  # TODO check
                    explanations.append((current_weight, 'start'))
                elif center <= 2 * n_window:                            # TODO check
                    explanations.append((current_weight, 'middle'))
                else:                                                   # TODO check
                    explanations.append((current_weight, 'end'))

        return max(explanations)[1] if explanations else ''

    @staticmethod
    def get_output_and_importance(model, face_vector, pose_vector, length):
        def save_activation(name_l, mod, inp, out_l):
            activations[name_l] = out_l

        for name, m in model.named_modules():
            m.register_forward_hook(partial(save_activation, name))

        activations = collections.defaultdict(list)

        out = model(face_vector, pose_vector, length)

        feature_importance = activations['softmax_att'].squeeze()

        return out, feature_importance


class AddresseeClassifierIJCNN(AddresseeClassifier):
    def __init__(self):
        # init common params
        super(AddresseeClassifierIJCNN, self).__init__()

        self.CNN_face_model = None
        self.CNN_pose_model = None
        self.LSTM_model = None
        self.CNN_face_file = None
        self.CNN_pose_file = None
        self.LSTM_file = None
        self.hidden_dim = None
        self.layer_dim = None

    def configure(self, rf):
        self.sequence_face = SequenceFace(self.device, True)
        self.utteranceFaces = UtteranceFace()

        self.transformed_face = TransformedFace(scale=True)
        super(AddresseeClassifierIJCNN, self).configure(rf)

        self.CNN_face_file = rf.check("CNN_face", yarp.Value(""), "module file (string)").asString()
        self.CNN_pose_file = rf.check("CNN_pose", yarp.Value(""), "module file (string)").asString()
        self.LSTM_file = rf.check("LSTM", yarp.Value(""), "module file (string)").asString()

        self.hidden_dim = rf.check("hidden_dim", yarp.Value(), "hidden dimension LSTM (int)").asInt32()
        self.layer_dim = rf.check("layer_dim", yarp.Value(), "layer dimension LSTM (int)").asInt32()

        self.CNN_face_model = CNN_face(os.path.join(self.classifier_path, self.CNN_face_file), self.device)
        self.CNN_pose_model = CNN_pose(os.path.join(self.classifier_path, self.CNN_pose_file), self.device)
        self.LSTM_model = LSTM(os.path.join(self.classifier_path, self.LSTM_file), self.hidden_dim, self.seq_len,
                               self.layer_dim, self.n_seq, self.num_classes, self.device)

        return True

    def classify_addressee(self, faces, poses):
        with torch.no_grad():
            # making sure we are running the sequences with cuda
            faces = faces.to(self.device)
            poses = poses.to(self.device)

            # getting the embedding by passing the sequences to the CNN layers
            face_embedding = self.CNN_face_model(faces)
            pose_embedding = self.CNN_pose_model(poses)

            multi_feature_embedding = torch.cat(
                (face_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding,
                 pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding,
                 pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding,
                 pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding,
                 pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding, pose_embedding), 1)

            output, current_batch = self.LSTM_model(multi_feature_embedding)
            confidence, predictions = torch.max(output, 1)

        return predictions, round(np.exp(confidence.item()), 2)

class AddresseeClassifierCombined(AddresseeClassifier):
    def __init__(self):
        # init common params
        super(AddresseeClassifierCombined, self).__init__()

        self.face_model = None
        self.pose_model = None
        self.att_model = None
        self.fusion_model = None

        self.classifier_path = None
        self.face_file = None
        self.pose_file = None
        self.att_file = None
        self.fusion_file = None

        self.face_embedding = None
        self.face_act = None
        self.face_hid = None
        self.face_out = None
        #self.face_drop = None

        self.pose_act = None
        self.pose_hid = None
        self.pose_out = None

        self.att_dim_inner = None
        #self.att_dim_feature = None
        #self.att_dim_k = None
        self.att_act = None
        self.att_dim_v = None
        self.att_dim_kq = None
        self.att_embed_kv = None
        self.att_embed_q = None

        self.fusion_act = None
        self.fusion_inp = None
        self.fusion_hid = None
        self.fusion_out = None
        self.fusion_drop = None

    def configure(self, rf):
        self.transformed_face = TransformedFace(scale=False)
        self.sequence_face = SequenceFace(self.device, False)
        self.utteranceFaces = UtteranceFace()

        # self.display_buf_image.resize(self.width_img, self.height_img)

        super(AddresseeClassifierCombined, self).configure(rf)

        self.face_file = rf.check("face", yarp.Value(""), "module file (string)").asString()
        self.pose_file = rf.check("pose", yarp.Value(""), "module file (string)").asString()
        self.att_file = rf.check("att", yarp.Value(""), "module file (string)").asString()
        self.fusion_file = rf.check("fusion", yarp.Value(""), "module file (string)").asString()
        self.face_embedding = rf.check("face_embedding", yarp.Value(),
                                  "size of the convolutional network (string)").asInt32()
        self.face_act = rf.check("face_act", yarp.Value(),
                                 "activation function of the face network (string)").asString()
        self.face_hid = rf.check("face_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.face_out = rf.check("face_out", yarp.Value(), "number of output neurons (int)").asInt32()
        #self.face_drop = rf.check("face_drop", yarp.Value(),
        #                          "dropout probability for the face network (float)").asFloat32()

        self.pose_act = rf.check("pose_act", yarp.Value(),
                                 "activation function of the pose network (string)").asString()
        self.pose_hid = rf.check("pose_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.pose_out = rf.check("pose_out", yarp.Value(), "number of output neurons (int)").asInt32()

        self.att_dim_inner = rf.check("att_dim_inner", yarp.Value(),
                                      "number of neurons att network (int)").asInt32()
        #self.att_dim_feature = rf.check("att_dim_feature", yarp.Value(),
        #                                "number of neurons att network (int)").asInt32()
        #self.att_dim_k = rf.check("att_dim_k", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_dim_v = rf.check("att_dim_v", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_dim_kq = rf.check("att_dim_kq", yarp.Value(), "number of neurons att network (int)").asInt32()
        self.att_act = rf.check("att_act", yarp.Value(),
                                "activation function of the att network (string)").asString()
        self.att_embed_kv = rf.check("att_embed_kv", yarp.Value(), "whether to use kv embedding").asBool()
        self.att_embed_q = rf.check("att_embed_q", yarp.Value(), "whether to use q embedding").asBool()

        self.fusion_act = rf.check("fusion_act", yarp.Value(),
                                   "activation function of the GRU network (string)").asString()
        self.fusion_inp = rf.check("fusion_inp", yarp.Value(), "input size of GRU network (int)").asInt32()
        self.fusion_hid = rf.check("fusion_hid", yarp.Value(), "number of hidden neurons (int)").asInt32()
        self.fusion_out = rf.check("fusion_out", yarp.Value(), "number of output neurons (int)").asInt32()
        self.fusion_drop = rf.check("fusion_drop", yarp.Value(),
                                    "dropout probability for the GRU network (float)").asFloat32()

        self.face_model = Face_ViT(os.path.join(self.classifier_path, self.face_file), self.device, self.face_embedding,
                                   self.face_hid, self.face_out)
        self.pose_model = pose(os.path.join(self.classifier_path, self.pose_file), self.pose_act, self.pose_hid,
                               self.pose_out, self.device)
        self.att_model = self_att(os.path.join(self.classifier_path, self.att_file), self.att_dim_inner,
                                  self.face_out, self.att_dim_kq, self.att_act, self.device)

        self.fusion_model = GRU_att(os.path.join(self.classifier_path, self.fusion_file), self.seq_len, self.n_seq,
                                 self.att_act, self.num_classes, self.face_out, self.pose_out, self.att_dim_kq,
                                 self.att_dim_v, self.att_embed_kv, self.att_embed_q, self.device, use_pose=False)

        return True

    def classify_addressee(self, faces, poses, send_msg=False):
        with torch.no_grad():
            # making sure we are running the sequences with cuda
            #faces = faces.reshape(faces.shape[0] * faces.shape[1], faces.shape[2], faces.shape[3], faces.shape[4])
            faces = faces.to(self.device)
            poses = poses.to(self.device)

            # getting the embedding by passing the sequences to the CNN layers
            face_embedding = self.face_model(faces)
            pose_embedding = self.pose_model(poses)

            merged_embedding = self.att_model(face_embedding, pose_embedding)

            output, current_batch = self.fusion_model(merged_embedding, poses=None)
            #output, current_batch = self.fusion_model(merged_embedding)

            confidence, predictions = torch.max(output, 1)

            #classes = {0: 'robot', 1: 'left', 2: 'right'}
            prob = np.exp(confidence.detach().cpu().numpy())  # exp due to log_softmax
            predictions_np = predictions.detach().cpu().numpy()

            probability = f'({float(prob) * 100:2.2f} %)'
            predicted_direction = self.classes[int(predictions_np)]
            print(predicted_direction, " ", probability)

            sentence = ""
            if send_msg:
                explanation = self.extract_time_explanations(merged_embedding, faces.shape[0])
                if explanation == '':
                    if int(predictions_np) == 0:
                        sentence = 'Based on your non-verbal behavior, I think you are talking to me'
                    else:
                        sentence = (f'Based on your non-verbal behavior, I guess you are talking to someone to my '
                                    f'{self.classes[int(predictions_np)]}')
                else:
                    if int(predictions_np) == 0:
                        sentence = (f'Based on you non-verbal behavior at the {explanation} of the interaction, '
                                    f'I think you are talking to me')
                    else:
                        sentence = (
                            f'Based on you non-verbal behavior at the {explanation} of the interaction, I guess you '
                            f'are talking to someone to my {self.classes[int(predictions_np)]}')

                info("FINAL: " + sentence + probability)
                info("END OF THE ESTIMATION\n\n")
            self.send_addressee_location(predicted_direction, round(np.exp(confidence.item()), 2), sentence)

        return predictions, round(np.exp(confidence.item()), 2)

    @staticmethod
    def get_face_vs_pose(model, face, pose):
        def save_activation(name_l, mod, inp, out_l):
            activations[name_l] = out_l

        for name, m in model.named_modules():
            m.register_forward_hook(partial(save_activation, name))

        activations = collections.defaultdict(list)
        out = model(face, pose)

        # activations = {itm: outputs for itm, outputs in activations.items()}  # probably not needed
        feature_importances = activations['feature_importance']

        return out, feature_importances
    
    def compute_importance(self, face, pose):
        with torch.no_grad():
            # making sure we are running the sequences with cuda
            face = face.to(self.device)
            pose = pose.to(self.device)

            # getting the embedding by passing the sequences to the CNN layers
            face_embedding = self.face_model(face)
            pose_embedding = self.pose_model(pose)

            _, importances = self.get_face_vs_pose(self.att_model.model, face_embedding, pose_embedding)

        return importances[0][0], importances[0][1]

    def compute_attention_map(self, face):

        with torch.no_grad():
            # making sure we are running the sequences with cuda
            face = face.to(self.device)

            # getting the embedding by passing the sequences to the CNN layers
            # face_embedding = self.face_model(face)

            orig_act, orig_tok = self.get_vit_activations(self.face_model.model, face, batch_size=1, repeats=1,
                                                          layer=5, dim=72, num_heads=6)

            transformations = [transforms.Normalize(mean=[0., 0., 0.], std=[1 / 0.229, 1 / 0.224, 1 / 0.225]),
                               transforms.Normalize(mean=[-0.485, -0.456, -0.406], std=[1., 1., 1.])]
            transf = transforms.Compose(transformations)

            face = face[:, :, :48, :48]
            face = transf(face)

            att_data = orig_act[0]  # the index determines the layer
            heat_map = HeatMap(att_data, patch_size=4, input_image=face, segmentation_mask=False)
            img, att_map, overlap = heat_map.visualize_map(visualize_token=True, merge_heads=True, blur_factor=2,
                                                           scale_overlay=2, save=False, save_to='save_dir',
                                                           save_name='')


        return img, att_map, overlap

    def transform_images_for_yarp(self, img_original, img_attention, img_overlap):

        colormap = 'viridis'
        cmap = plt.get_cmap(colormap)
        img_attention = np.squeeze(img_attention)
        attention_map = (cmap(img_attention)[:, :, :3] * 255).astype(
            np.uint8)  # Extract RGB channels
        img_original = (img_original * 255).astype(np.uint8)
        img_overlap = (img_overlap * 255).astype(np.uint8)

        return img_original, attention_map, img_overlap

    def extract_time_explanations(self, merged_vector, length):
        _, importance = self.get_frame_scores(self.fusion_model.model, merged_vector, length)
        importance = importance.detach().cpu().numpy()

        explanations = self.get_sentence(importance)

        return explanations

    @staticmethod
    def get_sentence(arr, threshold=0.03, n_window=None):
        seq_len = arr.shape[0]
        if n_window is None:
            n_window = seq_len // 3

        assert n_window <= seq_len

        actual = 0
        explanations = []

        while actual + n_window < seq_len:
            actual += 1
            current_weight = np.sum(arr[actual:actual + n_window])

            if current_weight > n_window / seq_len + threshold:
                center = (2 * actual + n_window) // 2
                if center <= n_window:
                    explanations.append((current_weight, 'start'))
                elif center <= 2 * n_window:
                    explanations.append((current_weight, 'middle'))
                else:
                    explanations.append((current_weight, 'end'))

        return max(explanations)[1] if explanations else ''

    @staticmethod
    def get_frame_scores(model, merged_vector, length):
        def save_activation(name_l, mod, inp, out_l):
            activations[name_l] = out_l

        for name, m in model.named_modules():
            m.register_forward_hook(partial(save_activation, name))

        activations = collections.defaultdict(list)

        out = model(merged_vector, pose=None, length=length)

        feature_importance = activations['softmax_att'].squeeze()

        return out, feature_importance

    @staticmethod
    def get_vit_activations(model, data, batch_size, repeats=1, layer=0, dim=72, num_heads=6):
        """
        Inspiration from here:
        https://gist.github.com/Tushar-N/680633ec18f5cb4b47933da7d10902af
        """
        model.eval()
        result = []
        outs = []

        def save_activation(name_l, mod, inp, out_l):
            activations[name_l] = out_l

        for name, m in model.named_modules():
            m.register_forward_hook(partial(save_activation, name))

        for k in range(repeats):
            activations = collections.defaultdict(list)

            out = model(data)

            outs.append(out.data.max(1, keepdim=True)[1])
            activations = {itm: outputs for itm, outputs in activations.items()}

            # tokens.append(cls_token)

            if isinstance(layer, int):
                q, k = activations[f'blocks.{layer}.attn.q_norm'][0], activations[f'blocks.{layer}.attn.k_norm'][0]
                scale = (dim // num_heads) ** -0.5
                q = q * scale
                attn = q @ k.transpose(-2, -1)
                attn = attn.softmax(dim=-1)
                result.append(attn)
            elif isinstance(layer, list):
                for la in layer:
                    q, k = activations[f'blocks.{la}.attn.q_norm'][0], activations[f'blocks.{la}.attn.k_norm'][0]
                    scale = (dim // num_heads) ** -0.5
                    q = q * scale
                    attn = q @ k.transpose(-2, -1)
                    attn = attn.softmax(dim=-1)
                    result.append(attn)

        return result, outs


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--version', type=str, default='att-combined')  # 'ijcnn', 'att-3', 'att-4', 'att4_vern_icub' # 'att-combined'

    # Initialise YARP
    if not yarp.Network.checkNetwork():
        info("Unable to find a yarp server exiting ...")
        sys.exit(1)

    yarp.Network.init()

    args = parser.parse_args()

    version = args.version

    if version == 'ijcnn':
        addressee_classification = AddresseeClassifierIJCNN()
        cfg = 'addresseeClassifier_ijcnn.ini'
    elif version == 'att-3':
        addressee_classification = AddresseeClassifierAtt3()
        cfg = 'addresseeClassifier_att-3.ini'
    elif version == 'att-4':
        addressee_classification = AddresseeClassifierAtt4()
        cfg = 'addresseeClassifier_att-4.ini'
    elif version == 'att4_vern_icub':
        addressee_classification = AddresseeClassifierAtt4()
        cfg = 'addresseeClassifier_att4_vern_icub.ini'
    elif version == 'att-combined':
        addressee_classification = AddresseeClassifierCombined()
        cfg = 'addresseeClassifier_att-combined.ini'
    else:
        raise ValueError('unsupported classifier type')
    resfinder = yarp.ResourceFinder()
    resfinder.setVerbose(True)
    resfinder.setDefaultContext('XAddresseeEstimation')
    resfinder.setDefaultConfigFile(cfg)

    if resfinder.configure(sys.argv):
        addressee_classification.runModule(resfinder)

    addressee_classification.close()
    sys.exit()
