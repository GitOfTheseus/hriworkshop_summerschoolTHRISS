from torchvision import transforms


class TransformedFace(object):
    def __init__(self, scale):
        if scale:
            self.trans_face = transforms.Compose([
                transforms.ToPILImage(),
                transforms.Resize((160, 160)),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406],
                                     std=[0.229, 0.224, 0.225])
            ])
        else:
            self.trans_face = transforms.Compose([
                transforms.ToPILImage(),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.5709, 0.4786, 0.4259],
                                     std=[0.2066, 0.2014, 0.1851])
            ])

    def __call__(self, face):
        face_transformed = self.trans_face(face)

        return face_transformed


class TransformedPose(object):
    def __init__(self):
        self.trans_pose = transforms.Compose([
            transforms.ToTensor(),
        ])

    def __call__(self, pose):
        pose_transformed = self.trans_pose(pose)

        return pose_transformed
