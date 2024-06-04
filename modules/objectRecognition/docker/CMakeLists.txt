cmake_minimum_required(VERSION 3.12)
project(object-recognition-docker)

# We need ICUBcontrib and YARP
find_package(ICUBcontrib REQUIRED)
find_package(YARP REQUIRED)

list(APPEND CMAKE_MODULE_PATH ${ICUBCONTRIB_MODULE_PATH})
include(ICUBcontribHelpers)
include(ICUBcontribOptions)
icubcontrib_set_default_prefix()

set(PROGRAM_PERMISSIONS_DEFAULT
        OWNER_WRITE OWNER_READ OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE)


set(DEMO_NAME "object-recognition" CACHE STRING "folder name inside the shared docker-compose path")
set(YARP_NAMESPACE "/root" CACHE STRING "YARP namespace /root (your PC) | /icub40 (Barry) | /icub03 (Reddy) | /citadel (Halfie)")
set(DOCKER_REGISTRY_IP "10.0.0.166" CACHE STRING "NAS IP = 10.0.0.166 (iCub network) | 12.245.71.15 (IIT network)")

# Configure the correct YARP namespace
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/docker-compose.yml ${CMAKE_CURRENT_SOURCE_DIR}/docker-compose.yml)

# Install the file
file(GLOB compose ${CMAKE_CURRENT_SOURCE_DIR}/docker-compose.yml)
yarp_install(FILES ${compose} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/docker-compose/${DEMO_NAME})