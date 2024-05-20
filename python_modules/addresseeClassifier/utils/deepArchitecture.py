import torch
import torch.nn as nn
from torch.optim import lr_scheduler

# torch.manual_seed(0)


# CNN model for images
class Conv_NN_Image(nn.Module):
    #  Determine what layers and their order in CNN object
    def __init__(self):
        super(Conv_NN_Image, self).__init__()

        self.conv_layer1 = nn.Conv2d(in_channels=3, out_channels=6, kernel_size=7)  # 1
        self.relu1 = nn.LeakyReLU()
        self.conv_layer2 = nn.Conv2d(in_channels=6, out_channels=8, kernel_size=5)  # 2
        self.relu2 = nn.LeakyReLU()
        self.max_pool1 = nn.MaxPool2d(kernel_size=2, stride=2)  # 3

        self.conv_layer3 = nn.Conv2d(in_channels=8, out_channels=12, kernel_size=5)  # 4
        self.relu3 = nn.LeakyReLU()
        self.conv_layer4 = nn.Conv2d(in_channels=12, out_channels=16, kernel_size=3)  # 5
        self.relu4 = nn.LeakyReLU()
        self.max_pool2 = nn.MaxPool2d(kernel_size=2, stride=2)  # 6

        self.fc1 = nn.Linear(18496, 4624)  # 7 (9248, 1156) (18496, 4624)
        self.relu5 = nn.LeakyReLU()  # 8
        self.fc2 = nn.Linear(4624, 578)  # 9 (1156, 578)

    # Progresses data across layers
    def forward(self, x):
        #print("0face", x.shape)
        out = self.conv_layer1(x)
        out = self.relu1(out)
        #print("conv1", out.shape)
        out = self.conv_layer2(out)
        #print("conv2", out.shape)
        out = self.relu2(out)
        #print("2", out.shape)
        out = self.max_pool1(out)
        #print("max1", out.shape)
        #print("3", out.shape)

        out = self.conv_layer3(out)
        #print("conv3", out.shape)
        #out = self.relu3(out)
        #print("4", out.shape)
        out = self.conv_layer4(out)
        #print("conv4", out.shape)
        out = self.relu4(out)
        #print("5", out.shape)
        out = self.max_pool2(out)
        #print("max2", out.shape)
        #print("6", out.shape)
        out = out.reshape(out.size(0), -1)
        #print("resize", out.shape)
        #print("7", out.shape)
        out = self.fc1(out)
        #print("fc1", out.shape)
        #print("8", out.shape)
        out = self.relu5(out)
        #print("9", out.shape)
        out = self.fc2(out)
        #print("fc2", out.shape)
        #print("10_face", out.shape)

        return out


# CNN model for poses
class Conv_NN_Pose(nn.Module):
    #  Determine what layers and their order in CNN object
    def __init__(self):
        super(Conv_NN_Pose, self).__init__()

        self.conv_layer1 = nn.Conv2d(in_channels=1, out_channels=16, kernel_size=(3, 1))
        self.relu1 = nn.LeakyReLU()
        self.conv_layer2 = nn.Conv2d(in_channels=16, out_channels=16, kernel_size=(3, 1))
        self.relu2 = nn.LeakyReLU()
        self.max_pool1 = nn.MaxPool2d(kernel_size=(2, 1), stride=(2, 1))

        self.conv_layer3 = nn.Conv2d(in_channels=16, out_channels=32, kernel_size=(3, 1))
        self.relu3 = nn.LeakyReLU()
        self.conv_layer4 = nn.Conv2d(in_channels=32, out_channels=32, kernel_size=(3, 1))
        self.relu4 = nn.LeakyReLU()
        self.max_pool2 = nn.MaxPool2d(kernel_size=(2, 2), stride=(2, 2))

        self.fc1 = nn.Linear(32, 24)
        self.relu5 = nn.LeakyReLU()
        self.fc2 = nn.Linear(24, 20)

    # Progresses data across layers
    def forward(self, x):
        #print("pose ", x.shape)
        out = self.conv_layer1(x)
        #out = self.relu1(out)
        #print("conv1", out.shape)
        out = self.conv_layer2(out)
        out = self.relu2(out)
        #print("conv2", out.shape)
        out = self.max_pool1(out)
        #print("max1", out.shape)

        out = self.conv_layer3(out)
        #out = self.relu3(out)
        #print("conv3", out.shape)
        out = self.conv_layer4(out)
        out = self.relu4(out)
        #print("conv4", out.shape)
        out = self.max_pool2(out)
        #print("max2", out.shape)
        out = out.reshape(out.size(0), -1)
        #print("reshape", out.shape)
        out = self.fc1(out)
        #print("fc1", out.shape)
        out = self.relu5(out)
        #print("9", out.shape)
        out = self.fc2(out)
        #print("fc2", out.shape)

        return out


# Creating a LSTM class
class LSTM_NN_Vision(nn.Module):
    #  Determine what layers and their order in CNN object
    def __init__(self, hidden_dim, seq_len, layer_dim, n_seq, num_classes, device):
        super(LSTM_NN_Vision, self).__init__()
        # Hidden dimensions
        self.hidden_dim = hidden_dim
        # Number of hidden layers
        self.layer_dim = layer_dim
        self.seq_len = seq_len
        self.n_seq = n_seq
        self.device = device

        self.lstm = nn.LSTM(input_size=1158, hidden_size=self.hidden_dim, num_layers=1, batch_first=True)  # 10
        #print(self.hidden_dim)
        # Readout layer
        self.fc3 = nn.Linear(self.hidden_dim, 128)  # 11
        self.relu1 = nn.LeakyReLU()
        self.fc4 = nn.Linear(128, num_classes)
        self.softmax = nn.LogSoftmax(dim=1)
        #self.softmax = nn.Softmax(dim=1)

    # Progresses data across layers
    def forward(self, x):
        current_batch = x.view(-1, self.seq_len, x.size(1)).size(0)

        self.hidden = (torch.zeros(1 * self.layer_dim, current_batch, self.hidden_dim).to(self.device),
                       torch.zeros(1 * self.layer_dim, current_batch, self.hidden_dim).to(self.device))

        #print(x.view(current_batch, self.seq_len, x.size(1)).shape)
        lstm_out, self.hidden = self.lstm(x.view(current_batch, self.seq_len, x.size(1)), self.hidden)
        #print("lstm ", lstm_out[:, -1, :].shape)

        out = self.fc3(lstm_out[:, -1, :])
        #print("fc3", out.shape)
        out = self.relu1(out)
        #print("13", out.shape)
        out = self.fc4(out)
        #print("fc4", out.shape)
        y_pred = self.softmax(out)
        #print("softmax", y_pred.shape)

        return y_pred, current_batch


def activation():
    return {'ReLU': nn.ReLU, 'Tanh': nn.Tanh, 'Sigm': nn.Sigmoid}


class FaceModel(nn.Module):
    def __init__(self, size, act, hid, out, drop):
        super(FaceModel, self).__init__()
        act = activation()[act]

        if size == 'small':
            chan = [6, 8, 12, 16]
        elif size == 'medium':
            chan = [8, 12, 16, 32]
        elif size == 'large':
            chan = [8, 16, 32, 64]
        else:
            raise ValueError(f'Convolutional network of size "{size}" is not supported!')

        self.conv_layer1 = nn.Conv2d(in_channels=3, out_channels=chan[0], kernel_size=5)
        self.a1 = act()
        self.conv_layer2 = nn.Conv2d(in_channels=chan[0], out_channels=chan[1], kernel_size=5)
        self.a2 = act()
        self.max_pool1 = nn.MaxPool2d(kernel_size=2, stride=2)
        self.d1 = nn.Dropout(p=drop)

        self.conv_layer3 = nn.Conv2d(in_channels=chan[1], out_channels=chan[2], kernel_size=5)
        self.a3 = act()
        self.conv_layer4 = nn.Conv2d(in_channels=chan[2], out_channels=chan[3], kernel_size=5)
        self.a4 = act()
        self.max_pool2 = nn.MaxPool2d(kernel_size=2, stride=2)
        self.d2 = nn.Dropout(p=drop)

        # 6 * 6 * channels
        self.fc1 = nn.Linear(36 * chan[3], hid)
        self.a5 = act()
        self.fc2 = nn.Linear(hid, out)

    def forward(self, x):
        # print(x.shape)
        # out = torch.flatten(x, 0, 1)
        out = self.conv_layer1(x)
        out = self.a1(out)
        out = self.conv_layer2(out)
        out = self.a2(out)
        out = self.max_pool1(out)
        out = self.d1(out)

        out = self.conv_layer3(out)
        out = self.a3(out)
        out = self.conv_layer4(out)
        out = self.a4(out)
        out = self.max_pool2(out)
        out = self.d2(out)

        out = torch.flatten(out, 1)
        out = self.fc1(out)
        out = self.a5(out)
        out = self.fc2(out)

        return out


class PoseModel(nn.Module):
    def __init__(self, act, hid, out):
        super(PoseModel, self).__init__()
        act = activation()[act]

        self.fc1 = nn.Linear(54, hid)
        self.a1 = act()
        self.fc2 = nn.Linear(hid, out)

    def forward(self, x):
        out = torch.flatten(x, 0, 1)
        out = torch.flatten(out, 1)
        out = self.fc1(out)
        out = self.a1(out)
        out = self.fc2(out)

        return out


class FusionModelGRU(nn.Module):
    def __init__(self, act, inp, hid, out, seq_len, n_seq, device, num_cls, drop):
        super(FusionModelGRU, self).__init__()
        act = activation()[act]

        self.seq_len = seq_len
        self.n_seq = n_seq
        self.device = device
        self.hidden_dim = hid

        self.gru = nn.GRU(input_size=inp, hidden_size=hid, num_layers=1, batch_first=True)
        self.d1 = nn.Dropout(p=drop)
        self.fc1 = nn.Linear(hid, out)
        self.a1 = act()
        self.fc2 = nn.Linear(out, num_cls)
        self.softmax = nn.LogSoftmax(dim=1)

    def forward(self, x):
        current_batch = x.view(-1, self.seq_len, x.size(1)).size(0)

        self.hidden = torch.zeros(1, current_batch, self.hidden_dim).to(self.device)

        gru_out, self.hidden = self.gru(x.view(current_batch, self.seq_len, x.size(1)), self.hidden)

        out = self.d1(gru_out[:, -1, :])
        out = self.fc1(out)
        out = self.a1(out)
        out = self.fc2(out)
        y_pred = self.softmax(out)

        return y_pred, current_batch


class SelfAttention(nn.Module):
    def __init__(self, dim_inner, dim_feature, dim_k, act):
        super(SelfAttention, self).__init__()
        act = activation()[act]

        self.dim_inner = dim_inner
        self.dim_feature = dim_feature
        self.dimK = dim_k

        self.WK = nn.Linear(self.dim_feature, self.dimK)

        # initialization of parameters with default normalisation
        # https://pytorch.org/docs/stable/generated/torch.nn.Linear.html
        wd_init = torch.rand(self.dim_inner) - 0.5
        wd_init *= 2 * torch.sqrt(torch.tensor(1/self.dim_feature))
        self.WD = nn.Parameter(wd_init, requires_grad=True)

        w_init = torch.rand(self.dim_inner, self.dimK) - 0.5
        w_init *= 2 * torch.sqrt(torch.tensor(1 / self.dimK))
        self.W = nn.Parameter(w_init, requires_grad=True)

        self.b = nn.Parameter(torch.randn(self.dim_inner), requires_grad=True)

        self.feature_importance = nn.Identity()

        self.act = act()

    def forward(self, face, pose):
        k_face = self.WK(face)
        k_pose = self.WK(pose)

        e_face = self.act(k_face @ self.W.T + self.b) @ self.WD
        e_pose = self.act(k_pose @ self.W.T + self.b) @ self.WD

        m = nn.Softmax(dim=1)
        e = m(torch.cat((torch.atleast_2d(e_face).T, torch.atleast_2d(e_pose).T), dim=1))

        e = self.feature_importance(e)  # due to easy activation extraction

        out = face.T * e[:, 0] + pose.T * e[:, 1]

        return out.T




class RecurrentAttentionGRU(nn.Module):
    def __init__(self, seq_len, n_seq, device, act, num_cls, dim_face, dim_pose, dim_kq=32, dim_v=64, use_kv_embed=True,
                 use_q_embed=False, use_pose=True):
        super(RecurrentAttentionGRU, self).__init__()
        act = activation()[act]

        self.dimQK = dim_kq
        self.dimV = dim_v

        self.dim_face = dim_face
        self.dim_pose = dim_pose
        self.dim_in = self.dim_face + self.dim_pose if use_pose else self.dim_face

        self.use_KV_embedding = use_kv_embed
        self.use_Q_embedding = use_q_embed
        self.dim_gru_inp = self.dimQK if self.use_Q_embedding else self.dim_in

        self.seq_len = seq_len
        self.device = device

        self.dim_hid = self.dim_in if not (self.use_Q_embedding and self.use_KV_embedding) else self.dimQK
        self.gru = nn.GRU(input_size=self.dim_gru_inp, hidden_size=self.dim_hid, num_layers=1, batch_first=True)

        self.WQ = nn.Linear(self.dim_in, self.dim_gru_inp) if self.use_Q_embedding else nn.Identity()
        self.WV = nn.Linear(self.dim_in, self.dimV) if self.use_KV_embedding else nn.Identity()
        self.WK = nn.Linear(self.dim_in, self.dim_hid) if self.use_KV_embedding else nn.Identity()

        self.MLP = nn.Linear(self.dimV if self.use_KV_embedding else self.dim_in, num_cls)

        self.activation = act()

        self.softmax_att = nn.Softmax(dim=2)
        self.log_softmax_out = nn.LogSoftmax(dim=1)

    def forward(self, face, pose=None, length=None):   #todo Boolean value of Tensor with more than one value is ambiguous
        if length is None:
            length = self.seq_len
        current_batch = face.view(-1, length, face.size(1)).size(0)

        if pose is not None:
            pose = pose.view(current_batch, length, pose.size(1))
            face = face.view(current_batch, length, face.size(1))
            inp = torch.cat((face, pose), 2)
        else:
            inp = face.view(current_batch, self.seq_len, face.size(1))

        inp_q_ = self.WQ(inp)  # torch.Size([16, 10, 32])
        inp_q_ = self.activation(inp_q_) if self.use_Q_embedding else inp_q_
        inp_k = self.WK(inp)  # torch.Size([16, 10, 32])
        inp_v = self.WV(inp)  # torch.Size([16, 10, 64])

        hidden = (torch.randn((1, current_batch, self.dim_hid))/100).to(self.device)
        _, hidden = self.gru(inp_q_, hidden)  # shape hidden: (1, 16, 32)
        query = hidden.permute(1, 0, 2)

        kq = torch.matmul(query, inp_k.permute(0, 2, 1)) * 1 / torch.sqrt(torch.tensor(query.shape[-1]))
        kq = self.softmax_att(kq)

        result = torch.matmul(kq, inp_v)[:, 0, :]

        result = self.activation(result)
        out = self.MLP(result)
        out = self.log_softmax_out(out)

        return out, current_batch



def build_models(d):
    device = d['device']
    model_cnn_image = Conv_NN_Image().to(device)
    model_cnn_pose = Conv_NN_Pose().to(device)
    model_lstm_vision = LSTM_NN_Vision(d['hidden_dim'], d['seq_len'], d['layer_dim'], d['n_seq'], d['num_classes'],
                                       device).to(device)

    cnn_image_d = {
        'name': 'cnn_image',
        'model': model_cnn_image,
        'SGD_opt': torch.optim.SGD(model_cnn_image.parameters(), lr=d['learning_rate'],
                                   weight_decay=0.005, momentum=0.9),# weight_decay = 0.001
        'Adam_opt': torch.optim.Adam(model_cnn_image.parameters(), lr=d['learning_rate'],
                                     weight_decay=0.000),  # weight_decay = 0.001
        'RMSprop_opt': torch.optim.RMSprop(model_cnn_image.parameters(), lr=d['learning_rate'],
                                           alpha=0.99, eps=1e-08, weight_decay=0, momentum=0, centered=False)
    }
    cnn_pose_d = {
        'name': 'cnn_pose',
        'model': model_cnn_pose,
        'SGD_opt': torch.optim.SGD(model_cnn_pose.parameters(), lr=d['learning_rate'],
                                   weight_decay=0.005, momentum=0.9),
        'Adam_opt': torch.optim.Adam(model_cnn_pose.parameters(), lr=d['learning_rate'],
                                     weight_decay=0.000),  # weight_decay = 0.001
        'RMSprop_opt': torch.optim.RMSprop(model_cnn_pose.parameters(), lr=d['learning_rate'],
                                           alpha=0.99, eps=1e-08, weight_decay=0, momentum=0, centered=False)
    }

    lstm_vision_d = {
        'name': 'lstm_vision',
        'model': model_lstm_vision,
        'SGD_opt': torch.optim.SGD(model_lstm_vision.parameters(), lr=d['learning_rate'],
                                   weight_decay=0.005, momentum=0.9),
        'Adam_opt': torch.optim.Adam(model_lstm_vision.parameters(), lr=d['learning_rate'],
                                     weight_decay=0.000),  # weight_decay = 0.001
        'RMSprop_opt': torch.optim.RMSprop(model_lstm_vision.parameters(), lr=d['learning_rate'],
                                           alpha=0.99, eps=1e-08, weight_decay=0, momentum=0, centered=False)
    }

    all_models = [cnn_image_d, cnn_pose_d, lstm_vision_d]

    for model in all_models:
        model['scheduler1'] = lr_scheduler.StepLR(model[d['optimizer1']], step_size=d['step_size'], gamma=0.1)
        model['scheduler2'] = lr_scheduler.StepLR(model[d['optimizer2']], step_size=d['step_size'], gamma=0.1)
        model['criterion'] = nn.NLLLoss()

        for i in range(len(list(model['model'].parameters()))):
            print(list(model['model'].parameters())[i].size())

    return cnn_image_d, cnn_pose_d, lstm_vision_d