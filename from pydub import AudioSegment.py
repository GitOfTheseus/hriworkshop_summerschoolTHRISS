from pydub import AudioSegment
from pydub.playback import play

# Carica il file audio
audio = AudioSegment.from_wav("test.wav")

# Riproduci il file audio
play(audio)