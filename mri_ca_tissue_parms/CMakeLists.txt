project(mri_ca_tissue_parms)
include_directories(${mri_ca_tissue_parms_SOURCE_DIR}
${INCLUDE_DIR_TOP} 
${VXL_INCLUDES} 
${MINC_INCLUDE_DIRS}) 

SET(mri_ca_tissue_parms_SRCS
mri_ca_tissue_parms.c
)


add_executable(mri_ca_tissue_parms ${mri_ca_tissue_parms_SRCS})
target_link_libraries(mri_ca_tissue_parms ${FS_LIBS})
install(TARGETS mri_ca_tissue_parms DESTINATION bin)	

