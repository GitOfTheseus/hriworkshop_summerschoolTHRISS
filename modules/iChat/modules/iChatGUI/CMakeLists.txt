# Copyright: (C) Robotics Brain and Cognitive Sciences (RBCS) - Istituto Italiano di Tecnologia
# Authors: Luca Garello
# CopyPolicy: Released under the terms of the GNU GPL v2.0.

##############################################################
# This MakeLists.txt is used to install the module. 
# It installs an .sh script file in the target_folder. 
# The .sh script file just activate the virtual environment 
# installed in Cognitive Interaction and run the main.py script.
##############################################################

# read name of parento folder, set it as project name
get_filename_component(MODULE_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

message("Installing ${MODULE_NAME}")

# Set the name of the executable file to be installed
set(SCRIPT_FILE_NAME ${MODULE_NAME})

# locate the "main" python script
set(PATH_TO_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/main.py)

# Write the script content
set(SCRIPT_CONTENT "#!/bin/bash\nsource ${PATH_TO_VENV}/bin/activate \npython ${PATH_TO_SCRIPT}")

# Write the script file
file(WRITE ${CMAKE_BINARY_DIR}/bin/${SCRIPT_FILE_NAME} ${SCRIPT_CONTENT})

# Make the script file executable
execute_process(COMMAND chmod +x ${CMAKE_BINARY_DIR}/bin/${SCRIPT_FILE_NAME})

# Output instructions to the user
message("Your ${SCRIPT_FILE_NAME} script has been created. You can now run it from terminal or yarpmanager.")

install(FILES ${CMAKE_BINARY_DIR}/bin/${SCRIPT_FILE_NAME} PERMISSIONS ${PROGRAM_PERMISSIONS_DEFAULT} DESTINATION bin)