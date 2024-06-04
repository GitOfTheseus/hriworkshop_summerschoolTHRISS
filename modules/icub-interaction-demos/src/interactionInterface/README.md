# InteractionInterface
Basic module that provide an RPC interface to execute action, commande on a script given in parameters.

## Parameters
    --config : script to load ( have to be in the ressourceFinder search path policy)
    --context : where the ResourceFinder will look for the script
    --audioPlayer : the audioPlayer to use we reocmmand installing Vlc as it can launch all type of audio natively
## Example of Usage
    Config is used to specify the script and the context tell ResourceFinder where to find it
    interactionInterface --config hand-scripting.sh --context handProfiler
On the RPC port (yarp rpc /interactionInterface) :
    
    Execute the command on the script :  exe <commande>
    Help information : help
    Play audio file : play <audioFile_absolute_path>

## Dependency 
    - YARP
    - To play Audio file with defqult audio player you need to have VLC install
## Authors

    Francesco Rea ( francesco.rea@iit.it) 
    Gonzalez Jonas (jonas.gonzalez@iit.it)
