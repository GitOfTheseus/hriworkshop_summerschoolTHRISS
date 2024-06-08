import yarp
import json

class Memory:

    def __init__(self):
        self.working_memory = {}

        print("initialization of the speech")

    def store_working_memory(self, object_category, object_position=None, object_direction="", name=""):

        self.working_memory[object_category]['position'] = object_position
        self.working_memory[object_category]['direction'] = object_direction
        self.working_memory[object_category]['name'] = name

    def retrieve_information(self, object_category, information='position'):

        try:

            return self.working_memory[object_category][information]

        except:

            print("\033[93m[WARNING] {}\033[00m".format(f"I don't know what {object_category} is"))

    def retrieve_info_by_info(self, type_info_known, info_known, type_info_unknown):

        try: 
            for obj, info in self.working_memory.items():
                if info[type_info_known] == info_known:
                    if obj[type_info_unknown]:
                        return obj[type_info_unknown]
        except:
            print("\033[93m[WARNING] {}\033[00m".format(f"problems in retrieving info in memory"))

    def store_long_term_memory(self, filename="object_info.json"):
        with open(filename, "w") as f:
            json.dump(self.working_memory, f, indent=4)

    def retrieve_long_term_memory(self, filename="object_info.json"):

        try:
            with open(filename, "r") as f:
                self.working_memory = json.load(f)

        except FileNotFoundError:

            print("No Long-Term Memory File found")

        except json.JSONDecodeError:
            print("An error occurred while decoding the JSON.")

        except Exception as e:
            print(f"An error occurred while loading the Long Term Memory: {e}")