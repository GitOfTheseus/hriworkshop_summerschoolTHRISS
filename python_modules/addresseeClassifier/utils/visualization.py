import numpy as np
import cv2
import os
from utils import util

# inspired by https://github.com/Daniil-Osokin/lightweight-human-pose-estimation.pytorch.git
class VisualPose:

    num_kpts = 18
    kpt_names = ['nose', 'neck',
                 'r_sho', 'r_elb', 'r_wri', 'l_sho', 'l_elb', 'l_wri',
                 'r_hip', 'r_knee', 'r_ank', 'l_hip', 'l_knee', 'l_ank',
                 'r_eye', 'l_eye',
                 'r_ear', 'l_ear']

    sigmas = np.array([.26, .79, .79, .72, .62, .79, .72, .62, 1.07, .87, .89, 1.07, .87, .89, .25, .25, .35, .35],
                      dtype=np.float32) / 10.0
    vars = (sigmas * 2) ** 2
    last_id = -1
    color = [0, 255, 0]
    BODY_PARTS_KPT_IDS = [[1, 2], [1, 5], [2, 3], [3, 4], [5, 6], [6, 7], [1, 8], [8, 9], [9, 10], [1, 11],
                          [11, 12], [12, 13], [1, 0], [0, 14], [14, 16], [0, 15], [15, 17], [2, 16], [5, 17]]
    BODY_PARTS_PAF_IDS = ([12, 13], [20, 21], [14, 15], [16, 17], [22, 23], [24, 25], [0, 1], [2, 3], [4, 5],
                          [6, 7], [8, 9], [10, 11], [28, 29], [30, 31], [34, 35], [32, 33], [36, 37], [18, 19],
                          [26, 27])

    def __init__(self, keypoints, img, new_size):
        super().__init__()
        self.keypoints = keypoints
        self.img = img
        self.width_img = img.shape[1]
        self.height_img = img.shape[0]
        self.new_size = new_size

    def shift(self):
        shift = self.width_img/2 - util.get_pose_center([self.keypoints])[0]
        for n, x in enumerate(self.keypoints):
            self.keypoints[n][0] += shift

    def crop(self):

        slice_to_crop = int((self.width_img-self.height_img)/2)
        squared_img_pose = self.img[0:self.height_img, slice_to_crop:self.width_img-slice_to_crop]
        return squared_img_pose

    def draw(self):

        assert self.keypoints.shape == (VisualPose.num_kpts, 3)

        for part_id in range(len(VisualPose.BODY_PARTS_PAF_IDS) - 2):
            kpt_a_id = VisualPose.BODY_PARTS_KPT_IDS[part_id][0]
            kpt_b_id = VisualPose.BODY_PARTS_KPT_IDS[part_id][1]
            if self.keypoints[kpt_a_id, 2] != 0:
                x_a, y_a = self.keypoints[kpt_a_id, 0:2]
                cv2.circle(self.img, (int(x_a), int(y_a)), 3, VisualPose.color, -1)
            if self.keypoints[kpt_b_id, 2] != 0:
                x_b, y_b = self.keypoints[kpt_b_id, 0:2]
                cv2.circle(self.img, (int(x_b), int(y_b)), 3, VisualPose.color, -1)
            if self.keypoints[kpt_a_id, 2] != 0 and self.keypoints[kpt_b_id, 2] != 0:
                cv2.line(self.img, (int(x_a), int(y_a)), (int(x_b), int(y_b)), VisualPose.color, 2)


class ModalityAttention:

   def __init__(self, path, filename, original_size):

       self.img_dir = os.path.join(path, filename)
       self.img = cv2.imread(filename=self.img_dir)
       self.img = cv2.cvtColor(self.img, cv2.COLOR_BGR2RGB)
       self.total_h, self.total_w, self.channels = self.img.shape
       self.original_size = original_size
       self.face_size = original_size
       self.pose_size = original_size
       self.constant = self.total_h / original_size
       self.empty_image = np.zeros((self.total_h, self.total_w, 3), dtype=np.uint8)


   def visualize(self, face_weight, pose_weight, face_img, pose_img):

       self.face_size = int(self.original_size * face_weight * self.constant)
       self.pose_size = int(self.original_size * pose_weight * self.constant)
       offset_face = int((self.total_h - self.face_size) / 2)
       offset_pose_y = int((self.total_h - self.pose_size) / 2)
       offset_pose_x = int(offset_pose_y + self.total_w/2)

       min_size = 50
       if self.pose_size < min_size:
           self.pose_size = min_size
       if self.face_size < min_size:
           self.face_size = min_size
       resized_face = cv2.resize(face_img, (self.face_size, self.face_size), interpolation=cv2.INTER_LINEAR)
       resized_pose  = cv2.resize(pose_img, (self.pose_size, self.pose_size), interpolation=cv2.INTER_LINEAR)

       img_copy = self.img.copy()
       img_copy[offset_face:offset_face+self.face_size, offset_face:offset_face+self.face_size, :] = resized_face
       img_copy[offset_pose_y:offset_pose_y + self.pose_size, offset_pose_x:offset_pose_x + self.pose_size, :] = resized_pose

       return img_copy

   def empty(self):

       return self.empty_image



