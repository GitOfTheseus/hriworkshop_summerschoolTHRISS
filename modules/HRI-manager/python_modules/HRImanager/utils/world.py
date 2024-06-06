import yarp

class World:

    def __init__(self, world_port):

        self.world_port = world_port
        self.objects_list = ["bowl", "Banana", "orange"]
        self.objects_coordinates = {}

        print("initialization of the world")

    def get_coordinates(self):

        for o in self.objects_list :
            self.objects_coordinates[o] = self.find(o)
        print(self.objects_coordinates)

    def find(self, object_category):

        if self.world_port.getOutputCount():
            request_bottle = yarp.Bottle()
            response_bottle = yarp.Bottle()

            request_bottle.clear()
            response_bottle.clear()

            request_bottle.addString("getPose")
            request_bottle.addString(object_category)

            self.world_port.write(request_bottle, response_bottle)

            coordinates = []
            for i in range(response_bottle.size()):
                coordinates.append(round(response_bottle.get(i).asFloat64(), 2))

            return coordinates

    def move(self, object_category, coordinates):
        if self.world_port.getOutputCount():
            request_bottle = yarp.Bottle()
            response_bottle = yarp.Bottle()

            request_bottle.clear()
            response_bottle.clear()

            request_bottle.addString("setPose")
            request_bottle.addString(object_category)
            print(request_bottle.toString())
            for i in coordinates:
                request_bottle.addFloat64(round(i,2))

            self.world_port.write(request_bottle, response_bottle)

    def lift(self, object_category):

        if object_category == "frisbee":
            object_category = "bowl"
        coordinates = self.objects_coordinates[object_category][:]
        if len(coordinates):
            coordinates[2] += 0.1
            self.move(object_category, coordinates)

    def lower(self, object_category):
        if object_category == "frisbee":
            object_category = "bowl"
        coordinates = self.objects_coordinates[object_category]
        self.move(object_category, coordinates)

    def update_world(self, event, object_category="frisbee"):

        if event == "grab":
            self.lift(object_category)

        elif event == "pose":
            self.lower(object_category)
