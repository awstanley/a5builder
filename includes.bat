@echo off
REM Builds in the includes to ensure Windows paths are used.
echo include("%CWD%/AllegroDependenciesWin32.cmake") >> "%CWD%/AllegroDependencies.cmake"
echo include("%CWD%/AllegroDependenciesGeneric.cmake") >> "%CWD%/AllegroDependencies.cmake"
echo include_directories("%CMAKE_INSTALL_PREFIX%/include") >> "%CWD%/AllegroDependencies.cmake"
exit