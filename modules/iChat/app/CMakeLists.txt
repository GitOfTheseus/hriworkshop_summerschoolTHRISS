# Copyright: (C) Robotics Brain and Cognitive Sciences (RBCS) - Istituto Italiano di Tecnologia
# Authors: Luca Garello
# CopyPolicy: Released under the terms of the GNU GPL v2.0.

cmake_minimum_required(VERSION 3.12)

file(GLOB scripts_template  ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.template)
file(GLOB scripts ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.xml)
file(GLOB conf_ini ${CMAKE_CURRENT_SOURCE_DIR}/conf/*.ini)

yarp_install(FILES ${conf_ini} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${PROJECT_NAME})
yarp_install(FILES ${scripts_template}  DESTINATION ${ICUBCONTRIB_APPLICATIONS_TEMPLATES_INSTALL_DIR})

# Install in the application directory (should be avoided)
yarp_install(FILES ${scripts}  DESTINATION ${ICUBCONTRIB_APPLICATIONS_INSTALL_DIR}/${PROJECT_NAME})
