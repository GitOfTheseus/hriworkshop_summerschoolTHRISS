import torch
import numpy as np
import collections
from functools import partial
from matplotlib import pyplot as plt
from mpl_toolkits.axes_grid1 import ImageGrid
from scipy.ndimage import gaussian_filter
from matplotlib import colormaps
import os
from torchvision import transforms


class HeatMap:
    def __init__(self, data, patch_size, input_image, segmentation_mask):
        """
        :param data: attention activation; Shape: (n_heads, n_patches^2+1, n_patches^2+1)
        :param patch_size: patch size of the network: (int)
        :param input_image: input to the RViT(); Shape: (1, 3, n_pixels_x, n_pixels_y)
        :param segmentation_mask: segmentation mask provided for PET dataset; Shape: (1, 1, n_pixels_x, n_pixels_y)
        """

        self.data = data
        self.patch_size = patch_size
        self.segmentation_mask = np.squeeze(np.array(segmentation_mask * 255, dtype=np.int32))

        input_image = (input_image.detach().cpu().numpy())
        input_image = np.moveaxis(input_image[0], 0, 2)
        self.input_image = input_image

    def update_data(self, data):
        self.data = data

    def _calculate_heatmap(self, vis_cls_tok=False, merge_heads=False):
        data = self.data.detach().cpu().numpy()
        _num_heads = data.shape[0]

        if vis_cls_tok:
            # extracting the attention matrix for the class token
            data = data[:, 0, 1:]  # the middle index specifies the index of attention mask (0 = cls_token)
        else:
            # sum of contributions (not only for the class token)
            data = np.sum(data, axis=1)[:, 1:]

        n_patch = int(np.sqrt((data.shape[-1])))
        data = data.reshape((_num_heads, n_patch, n_patch))
        data = np.repeat(data, self.patch_size, axis=1)
        data = np.repeat(data, self.patch_size, axis=2)

        if merge_heads:
            data = np.sum(data, axis=0)
            min_val = np.min(data, axis=1, keepdims=True)
            data -= min_val
            data /= np.max(data) - np.min(data)

        else:
            min_val = np.min(data, axis=(1, 2), keepdims=True)
            max_val = np.max(data, axis=(1, 2), keepdims=True)
            data -= min_val
            data /= max_val - min_val

            data -= 0.5
            data *= 2

        return data

    def visualize_map(self, visualize_token=True, merge_heads=True, blur_factor=0, scale_overlay=2, save=True,
                      save_to='', save_name='Image'):
        attention_map = self._calculate_heatmap(merge_heads=merge_heads, vis_cls_tok=visualize_token)
        if merge_heads:
            blurred = gaussian_filter(np.reshape(attention_map, (attention_map.shape[0],
                                                                 attention_map.shape[1], 1)), sigma=blur_factor)
            orig_im = self.input_image
            att_map = np.clip(blurred, a_min=0, a_max=1)
            overlay_with_orig = np.clip(self.input_image * blurred, a_min=0, a_max=1)

            return orig_im, att_map, overlay_with_orig

        else:
            _num_heads = attention_map.shape[0]
            fig, axs = plt.subplots(3, ncols=_num_heads)
            for i in range(_num_heads):
                axs[0][i].imshow(self.input_image)

                blurred = gaussian_filter(np.reshape(attention_map[i], (attention_map[i].shape[0],
                                                                        attention_map[i].shape[1], 1)),
                                          sigma=blur_factor)
                axs[1][i].imshow(blurred, cmap=colormaps['plasma'])

                blurred *= scale_overlay
                blurred = np.clip(blurred, 0, 1)
                axs[2][i].imshow(self.input_image * blurred)

                axs[0][i].axis('off')
                axs[1][i].axis('off')
                axs[2][i].axis('off')

        if save:
            plt.savefig(os.path.join(save_to, save_name + '.png'), dpi=400)
            plt.close()
        else:
            plt.suptitle('Attention map')
            plt.draw()
            plt.waitforbuttonpress(0)
            plt.close()