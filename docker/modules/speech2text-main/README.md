<div align="center">
  <p>
    <a align="center" href="" target="_blank">
      <img
        width="100%"
        src=".media/banner.png"
      >
    </a>
  </p>

  [![license](https://img.shields.io/pypi/l/supervision)](https://github.com/roboflow/supervision/blob/main/LICENSE.md)
  [![python-version](https://img.shields.io/pypi/pyversions/supervision)](https://badge.fury.io/py/supervision)

</div>

# Speech to Text
A module based on OPEN AI's [whisper](https://github.com/openai/whisper) that enables speech recognition.
This module reads from an audio stream and outputs the recognized text. 

 _Module Tested against: ***Python 3.10*** and ***YARP 3.8.1***_ 


# 🎛 Arguments
| Argument             | Description                                                                                               | Default      |
| -------------------- | --------------------------------------------------------------------------------------------------------- | ------------ |
| --name               | module name                                                                                               | speech2text  |
| --model              | model size                                                                                                | tiny         |
| --language           | selected language, see [WHISPER](https://github.com/openai/whisper) for the list of supported languages   | True         |
| --energy             | energy level for mic to detect (int)                                                                      | 300          |
| --dynamic_energy     | whether to use dynamic energy threshold (bool)                                                            | False        |
| --phrase_time_limit  | max speech length in seconds (int)                                                                        | 5            |
| --pause              | pause time before entry ends (float)                                                                      | 0.5          |
| --save_file          | whether to save the audio file clips (bool)                                                               | False        |
| --save_audio_dir     | where to log audio speech (string)                                                                        | /            |
| --use_local_mic      | use local microphone, not exposing the audio source on a Yarp port                                        | False        |


# 🌎 Available models and languages

There are five model sizes, four with English-only versions, offering speed and accuracy tradeoffs. Below are the names of the available models and their approximate memory requirements and relative speed. 


|  Size            | Parameters | English-only model | Multilingual model | Required VRAM | Relative speed |
|:----------------:|:----------:|:------------------:|:------------------:|:-------------:|:--------------:|
| tiny             |    39 M    |     `tiny.en`      |       `tiny`       |     ~1 GB     |      ~32x      |
| base             |    74 M    |     `base.en`      |       `base`       |     ~1 GB     |      ~16x      |
| small            |   244 M    |     `small.en`     |      `small`       |     ~2 GB     |      ~6x       |
| medium           |   769 M    |    `medium.en`     |      `medium`      |     ~5 GB     |      ~2x       |
| large            |   1550 M   |      N/A           |      `large`       |    ~10 GB     |       1x       |
| large-distil     |   756 M    |  `large-distil`    |        N/A         |      N/A      |      ~6x       |

The `.en` models for English-only applications tend to perform better, especially for the `tiny.en` and `base.en` models. We observed that the difference becomes less significant for the `small.en` and `medium.en` models.

Whisper's performance varies widely depending on the language. Check out the [benchmark](https://github.com/openai/whisper).
#### 🧪 Experimental 
We offer a distilled version of Whisper ([distill-whisper](https://huggingface.co/distil-whisper/distil-large-v2)) that is 2x smaller and 6x faster than the large model, while maintaining comparable accuracy. The distilled model is trained on a combination of LibriSpeech and Common Voice datasets, and is available in English only.


# 📝 Ports
The module reads from an audio stream port and outputs the recognized text.
<details> 
<summary>Click for list of opened ports</summary>

| Port name                 | Description                                                             |
| ------------------------- | ------------------------------------------------------------------------| 
| /speech2text/rpc          | RPC handle port used to control the module and set parameters on the go |
| /speech2text/speech:i     | audio input port                                                        |
| /speech2text/bookmarks:i  | port for reading bookmarks from acapela                                 |
| /speech2text/text:o       | recognized text output port                                             |

</details>


# 🎮 RPC Commands
The translation can be started and stopped sending the following RPC commands to the handler port ``/speech2text``:
<details> 
<summary>Click for list of available commands</summary>

| Command          | Description                                                                                               |
| -----------------| --------------------------------------------------------------------------------------------------------- |
| start            | starts the translation                                                                                    |
| stop             | stops the translation                                                                                     |
| set [lang]       | sets the language                                                                                         |
| set [thr]        | sets the energy level for mic to detect (int)                                                             |
| set [pause]      | sets the pause time before entry ends (float)                                                             |
| set [save]       | sets whether to save the audio file clips (bool)                                                          |
| set [dir]        | sets where to log audio speech (string)                                                                   |
| set [dyn]        | sets the audio threshold (bool)                                                                           |
| set [time]       | sets the phrase time limit for the recognizer in seconds (int)                                            |

</details>

# 💻 Installation
This module is installed using a different approch than the other modules that uses pyinstaller.
Due to the need of loading different models at runtime, the module is installed using a "_shared virtual environment_" approach.


<details> 
<summary>Ready to install? Click here!</summary>

clone this repo, ideally in the `\CognitiveInteraction` folder.

```bash
cd ../object_recognition

mkdir build && cd build

cmake .. /
make install
```

Easy right? But wait, what happend?
1) We created a _virtual env_ in the build folder.
2) An executable .sh script has been added to the iCubContrib folder. This script activates the virtual env and runs the module.

Now every time you modify your code placed in `\CognitiveInteraction` all the the changes have immediate effect on the main application.

 **NO NEED TO REBUILD/PYINSTALL THE WHOLE PROJECT.** 😎
</details>

## Authors and acknowledgment
This project is run by Luca Garello (luca.garello@iit.it).

## License
Whisper's code and model weights are released under the MIT License. 
