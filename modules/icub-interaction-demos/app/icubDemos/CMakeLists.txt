# Copyright: (C) 2013 RobotCub Consortium
# Authors: Francesco Rea
# CopyPolicy: Released under the terms of the GNU GPL v2.0.

cmake_minimum_required(VERSION 3.12)
set(appname icubDemos)

file(GLOB demos ${CMAKE_CURRENT_SOURCE_DIR}/conf/*.sh)
file(GLOB conf ${CMAKE_CURRENT_SOURCE_DIR}/conf/*.ini ${CMAKE_CURRENT_SOURCE_DIR}/conf/*.xml)
file(GLOB app ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.xml)
file(GLOB app_template ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.template)

message("PLEASE REVIEW AND MERGE ANY MODIFICATION ON THE INSTALLED SCRIPTS BEFORE OVERWRITING")

execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/check_diff.sh --dest ${CMAKE_INSTALL_PREFIX}/${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${appname} --conf ${demos} RESULT_VARIABLE RET_VAL)

yarp_install(PROGRAMS ${demos} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${appname})
yarp_install(FILES ${conf} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${appname})
yarp_install(FILES ${app} DESTINATION ${ICUBCONTRIB_APPLICATIONS_INSTALL_DIR})
yarp_install(FILES ${app_template} DESTINATION ${ICUBCONTRIB_APPLICATIONS_TEMPLATES_INSTALL_DIR})
