import torch


class SequenceFace(object):
    def __init__(self, device, scale):
        self.scale = scale
        if self.scale:
            self.sequence_face = torch.zeros([10, 3, 160, 160], dtype=torch.float32, device=device)
        else:
            self.sequence_face = torch.zeros([10, 3, 50, 50], dtype=torch.float32, device=device)

    def __call__(self, position, face_tensor):

        self.sequence_face[position] = face_tensor

        return self.sequence_face

    def get_empty(self, device):
        if self.scale:
            self.sequence_face = torch.zeros([10, 3, 160, 160], dtype=torch.float32, device=device)
        else:
            self.sequence_face = torch.zeros([10, 3, 50, 50], dtype=torch.float32, device=device)

        return self.sequence_face


class SequencePose(object):
    def __init__(self, device):
        self.sequence_pose = torch.zeros([10, 1, 18, 3], dtype=torch.float32, device=device)

    def __call__(self, position, pose_tensor):
        self.sequence_pose[position] = pose_tensor

        return self.sequence_pose

    def get_empty(self, device):
        self.sequence_pose = torch.zeros([10, 1, 18, 3], dtype=torch.float32, device=device)

        return self.sequence_pose


class UtteranceFace(object):
    def __init__(self):
        self.utterance_face = None

    def add_element(self, face_tensor):
        if self.utterance_face is None:
            self.utterance_face = face_tensor.unsqueeze(0)
        else:
            self.utterance_face = torch.cat((self.utterance_face, face_tensor.unsqueeze(0)), dim=0)


class UtterancePose(object):
    def __init__(self):
        self.utterance_pose = None

    def add_element(self, pose_tensor):
        pose_tensor = pose_tensor.float()
        if self.utterance_pose is None:
            self.utterance_pose = pose_tensor.unsqueeze(0)
        else:
            self.utterance_pose = torch.cat((self.utterance_pose, pose_tensor.unsqueeze(0)), dim=0)
