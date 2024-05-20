import math
import cv2
import numpy as np
import torch


def padRightDownCorner(img, stride, padValue):
    h = img.shape[0]
    w = img.shape[1]

    pad = 4 * [None]
    pad[0] = 0  # up
    pad[1] = 0  # left
    pad[2] = 0 if (h % stride == 0) else stride - (h % stride)  # down
    pad[3] = 0 if (w % stride == 0) else stride - (w % stride)  # right

    img_padded = img
    pad_up = np.tile(img_padded[0:1, :, :] * 0 + padValue, (pad[0], 1, 1))
    img_padded = np.concatenate((pad_up, img_padded), axis=0)
    pad_left = np.tile(img_padded[:, 0:1, :] * 0 + padValue, (1, pad[1], 1))
    img_padded = np.concatenate((pad_left, img_padded), axis=1)
    pad_down = np.tile(img_padded[-2:-1, :, :] * 0 + padValue, (pad[2], 1, 1))
    img_padded = np.concatenate((img_padded, pad_down), axis=0)
    pad_right = np.tile(img_padded[:, -2:-1, :] * 0 + padValue, (1, pad[3], 1))
    img_padded = np.concatenate((img_padded, pad_right), axis=1)

    return img_padded, pad


def draw_bodypose(canvas, candidate, subset):
    stickwidth = 4
    limbSeq = [[2, 3], [2, 6], [3, 4], [4, 5], [6, 7], [7, 8], [2, 9], [9, 10], \
               [10, 11], [2, 12], [12, 13], [13, 14], [2, 1], [1, 15], [15, 17], \
               [1, 16], [16, 18], [3, 17], [6, 18]]

    colors = [[255, 0, 0], [255, 85, 0], [255, 170, 0], [255, 255, 0], [170, 255, 0], [85, 255, 0], [0, 255, 0], \
              [0, 255, 85], [0, 255, 170], [0, 255, 255], [0, 170, 255], [0, 85, 255], [0, 0, 255], [85, 0, 255], \
              [170, 0, 255], [255, 0, 255], [255, 0, 170], [255, 0, 85]]

    joint_values = {}
    our_vector = []
    joint_vector = []
    joint_values_array = []
    #our_vector_split = []
    our_vector_array = np.array([])
    #print(subset)

    for n in range(len(subset)):
        joint_values = {}
        joint_vector = []
        for i in range(18):
            index = int(subset[n][i])
            if index == -1:
                #continue
                x, y, conf = [0,0,0]
            else:
                x, y, conf = candidate[index][0:3]
            cv2.circle(canvas, (int(x), int(y)), 4, colors[i], thickness=-1)
            joint_values[i] = (x, y, conf)
            joint_vector.append([x, y, conf])
            #our_vector.append(joint_values[i])
        our_vector.append(joint_vector)
        joint_values_array = np.array(joint_values)
        #our_vector_split = np.array_split(our_vector, (len(subset), 18))
        our_vector_array = np.array(our_vector, dtype=float)
        #print("joint_values for single person ", joint_values, type(joint_values), "\n")
        #print("joint_values_array for single person ", joint_values_array, type(joint_values_array), "\n")

    #print("the splitted vector\n", our_vector_split, type(our_vector_split), "\n")
    #print("our vector \n", our_vector_array, type(our_vector_array), "\n")
    #print("our_vector ", our_vector)

    """       
    for i in range(18):
        for n in range(len(subset)):
            index = int(subset[n][i])
            print(subset[n][i])
            if index == -1:
                continue
            x, y, conf = candidate[index][0:3]
            cv2.circle(canvas, (int(x), int(y)), 4, colors[i], thickness=-1)
            joint_values[i] = (x, y, conf)
    """
    for i in range(17):
        for n in range(len(subset)):
            index = subset[n][np.array(limbSeq[i]) - 1]
            if -1 in index:
                continue
            cur_canvas = canvas.copy()
            Y = candidate[index.astype(int), 0]
            X = candidate[index.astype(int), 1]
            mX = np.mean(X)
            mY = np.mean(Y)
            length = ((X[0] - X[1]) ** 2 + (Y[0] - Y[1]) ** 2) ** 0.5
            angle = math.degrees(math.atan2(X[0] - X[1], Y[0] - Y[1]))
            polygon = cv2.ellipse2Poly((int(mY), int(mX)), (int(length / 2), stickwidth), int(angle), 0, 360, 1)
            cv2.fillConvexPoly(cur_canvas, polygon, colors[i])
            canvas = cv2.addWeighted(canvas, 0.4, cur_canvas, 0.6, 0)
    # plt.imsave("preview.jpg", canvas[:, :, [2, 1, 0]])
    # plt.imshow(canvas[:, :, [2, 1, 0]])

    return canvas, our_vector_array

# transfer caffe model to pytorch which will match the layer name
def transfer_body(model, model_weights):
    transfered_model_weights = {}
    for weights_name in model.state_dict().keys():
        transfered_model_weights[weights_name] = model_weights['.'.join(weights_name.split('.')[1:])]
    return transfered_model_weights

def transfer(model, model_weights):

    transfered_model_weights = {}
    print(model.state_dict().keys())
    for weights_name in model.state_dict().keys():

        transfered_model_weights[weights_name] = model_weights['state_dict'][weights_name]

    return transfered_model_weights


def infer_fast(net, img, net_input_height_size, stride, upsample_ratio, cpu,
               pad_value=(0, 0, 0), img_mean=np.array([128, 128, 128], np.float32), img_scale=np.float32(1/256)):
    height, width, _ = img.shape
    scale = net_input_height_size / height

    scaled_img = cv2.resize(img, (0, 0), fx=scale, fy=scale, interpolation=cv2.INTER_LINEAR)
    scaled_img = normalize(scaled_img, img_mean, img_scale)
    min_dims = [net_input_height_size, max(scaled_img.shape[1], net_input_height_size)]
    padded_img, pad = pad_width(scaled_img, stride, pad_value, min_dims)

    tensor_img = torch.from_numpy(padded_img).permute(2, 0, 1).unsqueeze(0).float()
    if not cpu:
        tensor_img = tensor_img.cuda()

    stages_output = net(tensor_img)

    stage2_heatmaps = stages_output[-2]
    heatmaps = np.transpose(stage2_heatmaps.squeeze().cpu().data.numpy(), (1, 2, 0))
    heatmaps = cv2.resize(heatmaps, (0, 0), fx=upsample_ratio, fy=upsample_ratio, interpolation=cv2.INTER_CUBIC)

    stage2_pafs = stages_output[-1]
    pafs = np.transpose(stage2_pafs.squeeze().cpu().data.numpy(), (1, 2, 0))
    pafs = cv2.resize(pafs, (0, 0), fx=upsample_ratio, fy=upsample_ratio, interpolation=cv2.INTER_CUBIC)

    return heatmaps, pafs, scale, pad


def normalize(img, img_mean, img_scale):
    img = np.array(img, dtype=np.float32)
    img = (img - img_mean) * img_scale
    return img


def pad_width(img, stride, pad_value, min_dims):
    h, w, _ = img.shape
    h = min(min_dims[0], h)
    min_dims[0] = math.ceil(min_dims[0] / float(stride)) * stride
    min_dims[1] = max(min_dims[1], w)
    min_dims[1] = math.ceil(min_dims[1] / float(stride)) * stride
    pad = []
    pad.append(int(math.floor((min_dims[0] - h) / 2.0)))
    pad.append(int(math.floor((min_dims[1] - w) / 2.0)))
    pad.append(int(min_dims[0] - h - pad[0]))
    pad.append(int(min_dims[1] - w - pad[1]))
    padded_img = cv2.copyMakeBorder(img, pad[0], pad[2], pad[1], pad[3],
                                    cv2.BORDER_CONSTANT, value=pad_value)
    return padded_img, pad


def get_pose_center(vector):

    pose_centers_list = []
    for n in range(np.shape(vector)[0]):
        x_points = []
        # saving x values in the pose_vector in X_points
        for i in range(len(vector[n])):

            if vector[n][i][2] != 0:
                x_points.append(vector[n][i][0])
        # calculating the average of x values of each person
        average = sum(x_points) / len(x_points)
        pose_centers_list.append(average)

    return pose_centers_list


def transform_pixel_to_point(points_transformed, width_img, height_img):
    # transforming from [0,0,img.height,img.width] into points of [-1,-1,1,1] for the classification
    for n in range(np.shape(points_transformed)[0]):
        for i in range(len(points_transformed[n])):
            # transformation from  [0,0,img.height,img.width] to [0,0,2,2] to  have coordinates in pixels
            points_transformed[n][i][0] = (points_transformed[n][i][0] * 2) / width_img
            points_transformed[n][i][1] = (points_transformed[n][i][1] * 2) / height_img

            # transformation from [0,0,2,2] to [-1,-1,1,1]
            points_transformed[n][i][0] = points_transformed[n][i][0] - 1
            points_transformed[n][i][1] = points_transformed[n][i][1] - 1

    return points_transformed


def find_speaker(pose_vector_sorted, width_img, height_img):
    """
        Find the speaker from the stored array.
        :param array: The sorted array
        :return: The speaker element
             """
    speaker = np.zeros(shape=(1, 18, 3))
    pose_centers_list = get_pose_center(pose_vector_sorted)
    transformed_pose_centers_array = abs(np.array(pose_centers_list)-width_img/2)
    # get the index in pose_centers_list of the person closer to the center of the image
    index_speaker = transformed_pose_centers_array.tolist().index(np.min(transformed_pose_centers_array))
    # specifying that the 1st vector in the pose_vector_sorted represents the speaker
    speaker[0] = pose_vector_sorted[index_speaker]
    coordinates_speaker = [pose_centers_list[index_speaker], height_img]

    return speaker, coordinates_speaker


def sort_poses(pose_vector):

    if np.shape(pose_vector)[0] == 1:
        pose_vector_sorted = pose_vector
    else:
        pose_centers_list = get_pose_center(pose_vector)
        sorted_pose_centers_list = sorted(pose_centers_list)
        # sorting the vector to let the 1st one representing the speaker
        # if one person is detected the pose_vector_sorted is the same as the pose vector

        # if many people are detected, following the indexes of the values in  the sorted_pose_centers_list
        # the pose_vector_sorted will be created

        pose_vector_sorted = np.array([])
        for p in range(np.shape(pose_vector)[0]):
            if p == 0:
                pose_vector_sorted = pose_vector[sorted_pose_centers_list.index(pose_centers_list[p])]
            else:
                pose_vector_sorted = np.concatenate(
                    (pose_vector_sorted, pose_vector[sorted_pose_centers_list.index(pose_centers_list[p])]))
        pose_vector_sorted = np.split(pose_vector_sorted, np.shape(pose_vector)[0])

    return pose_vector_sorted

