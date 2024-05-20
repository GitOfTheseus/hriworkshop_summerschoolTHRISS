import torch
import timm
from utils.deepArchitecture import (Conv_NN_Image, Conv_NN_Pose, LSTM_NN_Vision, FaceModel, PoseModel, FusionModelGRU,
                                    SelfAttention, RecurrentAttentionGRU)


class CNN_face(object):
    def __init__(self, model_path, device):
        self.model = Conv_NN_Image()
        self.model.to(device)
        model_dict = torch.load(model_path)
        weights_dict = model_dict['state_dict']
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, images):
        face_embedding = self.model(images)

        return face_embedding


class CNN_pose(object):
    def __init__(self, model_path, device):
        self.model = Conv_NN_Pose()
        self.model.to(device)
        model_dict = torch.load(model_path)
        weights_dict = model_dict['state_dict']
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, poses):
        face_embedding = self.model(poses)

        return face_embedding


class LSTM(object):
    def __init__(self, model_path, hidden_dim, seq_len, layer_dim, n_seq, num_classes, device):
        self.model = LSTM_NN_Vision(hidden_dim, seq_len, layer_dim, n_seq, num_classes, device)
        self.model.to(device)
        model_dict = torch.load(model_path)
        weights_dict = model_dict['state_dict']
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, multi_feature_embedding):
        output, current_batch = self.model(multi_feature_embedding)

        return output, current_batch


class face(object):
    def __init__(self, model_path, size, act, hid, out, drop, device):
        self.model = FaceModel(size, act, hid, out, drop)
        self.model.to(device)
        weights_dict = torch.load(model_path)
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, images):
        face_embedding = self.model(images)
        return face_embedding


class pose(object):
    def __init__(self, model_path, act, hid, out, device):
        self.model = PoseModel(act, hid, out)
        self.model.to(device)
        weights_dict = torch.load(model_path)
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, poses):
        pose_embedding = self.model(poses)
        return pose_embedding


class self_att(object):
    def __init__(self, model_path, dim_inner, dim_feature, dim_k, act, device):
        self.model = SelfAttention(dim_inner, dim_feature, dim_k, act)
        self.model.to(device)
        weights_dict = torch.load(model_path)
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, faces, poses):
        attention = self.model(faces, poses)
        return attention


class fusion(object):
    def __init__(self, model_path, act, inp, hid, out, seq_len, n_seq, num_cls, drop, device):
        self.model = FusionModelGRU(act, inp, hid, out, seq_len, n_seq, device, num_cls, drop)
        self.model.to(device)
        weights_dict = torch.load(model_path)
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, multi_feature_embedding):
        output, current_batch = self.model(multi_feature_embedding)
        return output, current_batch


class GRU_att(object):
    def __init__(self, model_path, seq_len, n_seq, act, num_cls, dim_face, dim_pose, dim_kq, dim_v, use_kv_embed,
                 use_q_embed, device, use_pose=True):
        self.model = RecurrentAttentionGRU(seq_len, n_seq, device, act, num_cls, dim_face, dim_pose, dim_kq, dim_v,
                                           use_kv_embed, use_q_embed, use_pose=use_pose)
        self.model.to(device)
        print(model_path)
        weights_dict = torch.load(model_path)
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, faces, poses, length=None):
        output, current_batch = self.model(faces, poses, length)
        return output, current_batch



class Face_ViT(object):
    def __init__(self, model_path, device, face_size, face_hid, face_out):
        self.model = timm.models.vision_transformer.VisionTransformer(img_size=50, patch_size=4, in_chans=3,
                                                                      num_classes=face_out, embed_dim=face_size,
                                                                      depth=face_hid, num_heads=6).to(device)
        self.model.to(device)
        weights_dict = torch.load(model_path)
        self.model.load_state_dict(weights_dict)
        self.model.eval()

    def __call__(self, images):
        face_embedding = self.model(images)

        return face_embedding


