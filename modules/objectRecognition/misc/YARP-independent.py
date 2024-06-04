import supervision as sv
from ultralytics import YOLO
from super_gradients.training import models
from super_gradients.common.object_names import Models
from PIL import Image
import numpy as np
import cv2
import os
import sys 

# Model Type	Pre-trained Weights	                                                                                        Task
# YOLOv8	    yolov8n.pt, yolov8s.pt, yolov8m.pt, yolov8l.pt, yolov8x.pt	                                                Detection
# YOLOv8-seg	yolov8n-seg.pt, yolov8s-seg.pt, yolov8m-seg.pt, yolov8l-seg.pt, yolov8x-seg.pt	                            Instance Segmentation
# YOLOv8-pose	yolov8n-pose.pt, yolov8s-pose.pt, yolov8m-pose.pt, yolov8l-pose.pt, yolov8x-pose.pt, yolov8x-pose-p6.pt	    Pose/Keypoints
# YOLOv8-cls	yolov8n-cls.pt, yolov8s-cls.pt, yolov8m-cls.pt, yolov8l-cls.pt, yolov8x-cls.pt	                            Classification
# YOLOv8-face   yolov8n-face.pt                                                                                             Face Detection


task = "pose"
dimension = "n"
annotator = "BoundingBox"
use_int8 = False #enable int8 quantization (YOLO NAS detection only)
track = True

#load image
frame = cv2.imread(os.path.join(os.getcwd(), "misc/group.jpg"))

# we install models in models folder
# os.chdir("models")

if task == "detection":
    if use_int8:
        model = models.get('yolo_nas_' + dimension + '_int8', pretrained_weights="coco")
    else:
        model = YOLO('yolov8' + dimension + '.pt')

elif task == "classification":
    model = YOLO('yolov8' + dimension + '-cls.pt')
elif task == "pose":
    model = YOLO('yolov8' + dimension + '-pose.pt')
elif task == "segmentation":
    model = YOLO('yolov8' + dimension + '-seg.pt')
elif task == "face":
    # download file from url 
    url = "https://github.com/akanametov/yolov8-face/releases/download/v0.0.0/yolov8n-face.pt"
    model = YOLO(url)
else:
    print("Task: " + task + " not yet implemented")
if track:
    byte_tracker = sv.ByteTrack(track_buffer=120)

# open webcam
cap = cv2.VideoCapture(0)
#create window
cv2.namedWindow("annotated", cv2.WINDOW_NORMAL)


while True:
    # Capture frame-by-frame
    ret, frame = cap.read()
    if not ret:
        break

    if use_int8:
        result = list(model.predict(frame, conf=0.60))[0]
        detections = sv.Detections.from_yolo_nas(result)
    else:
        result = model(frame)[0]
        detections = sv.Detections.from_ultralytics(result)

    if track:
        detections = byte_tracker.update_with_detections(detections)

    print(detections)


    #assign detections to variables
    boxes = detections.xyxy
    scores = detections.confidence

    if task == "pose":
        for r in result:
            annotated_image = r.plot()  # plot a BGR numpy array of predictions
            keyp = Image.fromarray(annotated_image[..., ::-1])  # RGB PIL image
            cv2.imshow("annotated", annotated_image)

    #TODO: chek if this annotator is compatible with the task
    # annotate image
    if annotator == "BoundingBox":
        
        box_annotator = sv.BoxAnnotator()
        labels = [
            f"{model.model.names[class_id]} {confidence:.2f}"
            for class_id, confidence
            in zip(detections.class_id, detections.confidence)
        ]

        classes = [
            f"{model.model.names[class_id]}"
            for class_id in detections.class_id
        ]

        # beta function
        if track:
            labels = [
                f"#{tracker_id} {model.model.names[class_id]} {confidence:0.2f}"
                for _, _, confidence, class_id, tracker_id
                in detections
            ]

        annotated_image = box_annotator.annotate(frame.copy(), detections=detections, labels=labels)

    elif annotator == "BoxCorner":
        corner_annotator = sv.BoxCornerAnnotator()
        annotated_image = corner_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "BoxMask":
        box_mask_annotator = sv.BoxMaskAnnotator()
        annotated_image = box_mask_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "Circle":
        circle_annotator = sv.CircleAnnotator()
        annotated_image = circle_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "Ellipse":
        ellipse_annotator = sv.EllipseAnnotator()
        annotated_image = ellipse_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "Mask":
        mask_annotator = sv.MaskAnnotator(color_map="index")
        annotated_image = mask_annotator.annotate(frame.copy(), detections=detections)

    elif annotator == "Label":
        label_annotator = sv.LabelAnnotator(text_position=sv.Position.CENTER)
        classes = [
            f"{model.model.names[class_id]}"
            for class_id in detections.class_id
        ]
        annotated_image = label_annotator.annotate(scene=frame.copy(), detections=detections, labels=classes)

    elif annotator == "Blur":
        blur_annotator = sv.BlurAnnotator()
        annotated_image = blur_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "Trace":
        trace_annotator = sv.TraceAnnotator(text_position=sv.Position.CENTER)
        annotated_image = trace_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "HeatMap":
        # video only 
        heat_map_annotator = sv.HeatMapAnnotator(position=sv.Position.CENTER)
        annotated_image = heat_map_annotator.annotate(scene=frame.copy(), detections=detections)

    elif annotator == "Halo":
        halo_annotator = sv.HaloAnnotator()
        annotated_image = halo_annotator.annotate(scene=frame.copy(), detections=detections)

    else:
        print("Annotation: " +  annotator + " not yet implemented")

    #imshow
    #cv2.imshow("annotated", annotated_image)

    # Exit with ESC
    k = cv2.waitKey(1) & 0xff
    if k == 27:
        break
