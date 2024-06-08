# Copyright: (C) 2024 CONTACT Cognitive Architecture for Collaborative Technologies
# Authors: Carlo Mazzola
# CopyPolicy: Released under the terms of the GNU GPL v2.0.

cmake_minimum_required(VERSION 3.5)
SET(PROJECT_NAME "HRIworkshopTHRISS")
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 11)

find_package(ICUBcontrib REQUIRED)
find_package(YARP REQUIRED)

list(APPEND CMAKE_MODULE_PATH ${ICUBCONTRIB_MODULE_PATH})

include(ICUBcontribHelpers)
include(ICUBcontribOptions)
icubcontrib_set_default_prefix()

add_subdirectory(modules)
add_subdirectory(app)

icubcontrib_add_uninstall_target()  
