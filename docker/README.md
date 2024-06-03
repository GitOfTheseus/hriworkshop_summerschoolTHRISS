# SummerSchool
This repo offers a docker to test social behaivours on a simulated iCub robot.
In the docker you will find:
- YARP 3.9
- Gazebo

Sofware modules from iit's CONTACT unit.
- speech2text
- face recognition
- ...

# Run the environment

``` docker compose -f "compose.yaml" up -d --build ```


# Run the docker (deprecated)
Build the docker \
```docker pull gazebo```

Run container \
```sudo docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ --name gazebo gazebo```

Run terminal from docker \
```sudo  docker exec -it gazebo bash```

from another terminal run 
```docker exec -it summerschool-summerschool-1 bash```

From new docker terminal \
```gzclient```