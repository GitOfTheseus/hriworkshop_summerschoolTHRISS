import cv2
import numpy as np
import math
import time
from scipy.ndimage.filters import gaussian_filter
import matplotlib.pyplot as plt
import matplotlib
import torch
from torchvision import transforms
import utils.util
import copy
from utils.model import bodypose_model
from utils.with_mobilenet import PoseEstimationWithMobileNet
from modules_lightweight.keypoints import extract_keypoints, group_keypoints
from modules_lightweight.load_state import load_state
from modules_lightweight.pose import Pose, track_poses

class Body_Lightweight(object):
    def __init__(self, model_path, device):
        self.model = PoseEstimationWithMobileNet()
        checkpoint = torch.load(model_path, map_location=device)
        load_state(self.model, checkpoint)
        self.model.eval()
        if torch.cuda.is_available():
            self.cpu = False
            self.model = self.model.cuda()

    def __call__(self, orig_img):
        stride = 8
        upsample_ratio = 4
        num_keypoints = Pose.num_kpts
        previous_poses = []
        delay = 1
        height_size = 256
        track = 1
        smooth = 1
        oriImg = copy.deepcopy(orig_img)
        heatmaps, pafs, scale, pad = utils.util.infer_fast(self.model, oriImg, height_size, stride, upsample_ratio, self.cpu)
        #print(pad, scale)
        total_keypoints_num = 0
        all_keypoints_by_type = []
        for kpt_idx in range(num_keypoints):  # 19th for bg
            total_keypoints_num += extract_keypoints(heatmaps[:, :, kpt_idx], all_keypoints_by_type,
                                                     total_keypoints_num)

        pose_entries, all_keypoints = group_keypoints(all_keypoints_by_type, pafs)

        for kpt_id in range(all_keypoints.shape[0]):
            all_keypoints[kpt_id, 0] = (all_keypoints[kpt_id, 0] * stride / upsample_ratio - pad[1]) / scale
            all_keypoints[kpt_id, 1] = (all_keypoints[kpt_id, 1] * stride / upsample_ratio - pad[0]) / scale
            all_keypoints[kpt_id, 2] = all_keypoints[kpt_id, 2]

        current_poses = []
        pose_vector = np.array([])
        #print("n people", len(pose_entries))

        for n in range(len(pose_entries)):
            if len(pose_entries[n]) == 0:
                continue
            pose_keypoints = np.ones((num_keypoints, 3)) * -1
            print_keypoints = np.ones((num_keypoints, 2), dtype=np.int32) * -1
            for kpt_id in range(num_keypoints):
                if pose_entries[n][kpt_id] == -1.0:  # keypoint was found
                    pose_keypoints[kpt_id, 0] = 0
                    pose_keypoints[kpt_id, 1] = 0
                    pose_keypoints[kpt_id, 2] = 0
                elif pose_entries[n][kpt_id] != -1.0:  # keypoint was found
                    pose_keypoints[kpt_id, 0] = round(all_keypoints[int(pose_entries[n][kpt_id]), 0])
                    pose_keypoints[kpt_id, 1] = round(all_keypoints[int(pose_entries[n][kpt_id]), 1])
                    pose_keypoints[kpt_id, 2] = all_keypoints[int(pose_entries[n][kpt_id]), 2]
                    print_keypoints[kpt_id, 0] = int(round(all_keypoints[int(pose_entries[n][kpt_id]), 0]))
                    print_keypoints[kpt_id, 1] = int(round(all_keypoints[int(pose_entries[n][kpt_id]), 1]))
            # print("pose_keypoints \n", pose_keypoints)
            # print("print_keypoints \n", print_keypoints)
            pose = Pose(print_keypoints, pose_entries[n][18])
            current_poses.append(pose)
            if n == 0:
                pose_vector = pose_keypoints
            else:
                pose_vector = np.concatenate((pose_vector, pose_keypoints))
        if len(pose_entries) != 0:
            pose_vector = np.split(pose_vector, len(pose_entries))
            #print(pose_vector)

        if track:
            track_poses(previous_poses, current_poses, smooth=smooth)
            previous_poses = current_poses
        for pose in current_poses:
            pose.draw(oriImg)
        oriImg = cv2.addWeighted(orig_img, 0.6, oriImg, 0.4, 0)

        """
        for pose in current_poses:
            cv2.rectangle(oriImg, (pose.bbox[0], pose.bbox[1]),
                          (pose.bbox[0] + pose.bbox[2], pose.bbox[1] + pose.bbox[3]), (0, 255, 0))
            if track:
                cv2.putText(oriImg, 'id: {}'.format(pose.id), (pose.bbox[0], pose.bbox[1] - 16),
                            cv2.FONT_HERSHEY_COMPLEX, 0.5, (0, 0, 255))
                            """

        return oriImg, pose_vector

