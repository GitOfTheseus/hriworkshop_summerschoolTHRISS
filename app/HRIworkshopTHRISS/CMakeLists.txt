# Copyright: (C) 2023 Istituto Italiano di Tecnologia | Robotics, Brains and Cognitive Science
# Authors: Luca Garello
# CopyPolicy: Released under the terms of the GNU GPL v2.0.


# NOTE:
# The .sh files and the .ini files are installed in context folders named after the appname. 
# The .xml files and the .xml templates are installed in the icubcontrib applications folder.

set(APPNAME ${PROJECT_NAME})

file(GLOB actions ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.sh)
file(GLOB conf ${CMAKE_CURRENT_SOURCE_DIR}/conf/*.ini ${CMAKE_CURRENT_SOURCE_DIR}/conf/*.txt)
file(GLOB scripts ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.xml)
#file(GLOB scripts ${CMAKE_CURRENT_SOURCE_DIR}/scripts/*.template)

		
yarp_install(PROGRAMS ${actions} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${APPNAME})
yarp_install(FILES ${conf} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${APPNAME})
#yarp_install(FILES ${scripts} DESTINATION ${ICUBCONTRIB_APPLICATIONS_TEMPLATES_INSTALL_DIR})
yarp_install(FILES ${scripts} DESTINATION ${ICUBCONTRIB_APPLICATIONS_INSTALL_DIR})
message(STATUS "context destination: ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${APPNAME}")
message(STATUS "template destination: ${ICUBCONTRIB_APPLICATIONS_INSTALL_DIR}")
