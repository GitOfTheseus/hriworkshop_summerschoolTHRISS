FROM 10.0.0.166:5000/superbuild/22.04/3.10

# install basic dependencies
RUN apt update

# Copy the code
COPY . /object_recognition

# Build and Install
RUN /bin/bash -c "mkdir /object_recognition/build; cd /object_recognition/build; cmake ../; make install"

COPY docker/_run_face_detector.sh /run_face_detector.sh
RUN chmod +x /run_face_detector.sh