
class Cube:

    def __init__(self, event_port):

        self.event_port = event_port

        print("initialization of the cube processor")

    def read_event(self):

        if self.event_port.getInputCount():
            event_bottle = self.event_port.read(False)
            if event_bottle is not None:
                event = event_bottle.get(100).asString() #100 is not the correct number... what is it?
                return event

    def read_and_process(self, object_category=None):

        event = self.read_event()
        if event in []:  # which events ? read from the correct port to fill the list with the possible ones!
            return event
