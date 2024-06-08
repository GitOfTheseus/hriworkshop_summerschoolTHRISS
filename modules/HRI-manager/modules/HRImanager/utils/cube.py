
class Cube:

    def __init__(self, event_port):

        self.event_port = event_port

        print("initialization of the cube processor")

    def read_event(self):

        if self.event_port.getInputCount():
            event_bottle = self.event_port.read(False)
            if event_bottle is not None:
                event = event_bottle.get(0).asString()
                return event

    def process_event(self, event, object_category=None):

        if event == "grab":
            print(event)
            # todo lift the object on the table (if object is not None, lift that object)
        elif event == "pose":
            print(event)
            # todo lay the object down on the table (if object is not None, lay that object down)

    def read_and_process(self, object_category=None):

        event = self.read_event()
        #self.process_event(event, object_category)
        if event in ["grab", "pose"]:
            return event
