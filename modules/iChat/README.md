# iChat
This repository contains a conversational framework for iCub. 
This app allows users to freely chat with the robot using natural language.

## Arguments
| argument name       | description                                           |
| :------------------ | :---------------------------------------------------- |
| `name`              | root name of the module                               |
| `model`             | model name                                            |
| `top_k`             | number of top tokens to consider                      |
| `top_p`             | probability of the next token being sampled           |
| `temperature`       | temperature of the next token being sampled           |
| `max_tokens`        | maximum number of tokens to generate                  |
| `repetition_penalty`| repetition penalty                                    |


## Models
It it possible to load different models offered by TOGETHER's API, here we list just a few of them.
The model can be selected by setting the `model` argument.

| model name                                 | description                                           |
| :----------------------------------------  | :---------------------------------------------------  |  
| togethercomputer/llama-2-70b-chat          | llama2 model with 70 billion parameters               |
| togethercomputer/llama-2-13b-chat          | llama2 model with 13 billion parameters               |
| togethercomputer/llama-2-7b-chat           | llama2 model with 7 billion parameters                |
| mistralai/Mistral-7B-Instruct-v0.1         | mistral model with 7 billion parameters               |



## Ports 
| input ports          | description                                           |
| :------------------- | :---------------------------------------------------- |  
| `/iChat/question:i`  | receives textual questions [string]                   |
| `/iChat/answer:o`    | publishes the robot's answer [string]                 |
| `/iChat         `    | handler                                               |




## Installation
- Clone this repository to your local machine ( preferably in  `../src/robot/CognitiveInteraction` ).

- Compile and and install:

```bash
cd ../iChat

mkdir build && cd build

cmake ../

make install
```
