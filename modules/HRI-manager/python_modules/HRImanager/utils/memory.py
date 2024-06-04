import yarp


class Memory:

    def __init__(self):
        self.memory_dict = {}

        print("initialization of the speech")

    def store(self, object_category, object_position):

        self.memory_dict[object_category] = object_position

    def retrieve_position(self, object_category):

        try:

            return self.memory_dict[object_category]

        except:

            print("\033[93m[WARNING] {}\033[00m".format(f"I don't know what {object_category} is"))

    def retrieve_name(self, object_position):

        try:

            object_category = [k for k, v in self.memory_dict.items() if v == object_position]

            return object_category

        except:

            print("\033[93m[WARNING] {}\033[00m".format(f"I don't know the name of what's in {object_position}"))
