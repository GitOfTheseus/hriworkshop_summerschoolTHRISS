from enum import Enum


class State(Enum):

    INITIALIZATION = 0
    WAITING_FOR_STIMULI = 1
    REASONING = 2
    ACTING_TOWARD_ENVIRONMENT = 3

