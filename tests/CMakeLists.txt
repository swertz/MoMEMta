# Test executables

## Phase-space volumes

### BlockD

add_executable(test_psVol_blockD "phaseSpaceVolume/blockD.cc")
target_link_libraries(test_psVol_blockD momemta)
set_target_properties(test_psVol_blockD PROPERTIES OUTPUT_NAME
  "phaseSpaceVolume_blockD.exe")

## Cross-sections 

### BlockD, pp > t t~, (t > w+ b, w+ > mu+ vm), (t~ > w- b~, w- > mu- vm~) == 6.73 +- 0.02 pb (MadGraph)

add_executable(test_XS_blockD_ttx_dilep "crossSections/blockD_ttx_dilep.cc")
target_link_libraries(test_XS_blockD_ttx_dilep momemta)
set_target_properties(test_XS_blockD_ttx_dilep PROPERTIES OUTPUT_NAME
  "crossSection_blockD_ttx_dilep.exe")
