@echo off
REM Order is important here, as there are some dependencies and things
REM which need to be handled sensibly.
REM
REM I should point out I am NOT a huge fan of batch files, so this is done
REM in a way which works and I can maintain (so there are probably massive
REM stylistic issues here).

REM This can be tweaked, but I haven't tested anything other than VC2015 x86...

set GENERATOR="Visual Studio 14 2015" 

REM If you do change it, find and replace the following:
REM /p:PlatformToolset=v140

REM Update path to search for our stuff first ...
REM Yes, it shouldn't be first, but you can't assume things won't be in the path!
SET PATH=%CMAKE_INSTALL_PREFIX%;%CMAKE_INSTALL_PREFIX%/include;%CMAKE_INSTALL_PREFIX%/lib;%PATH%

REM Includes
SET INCLUDE=%CMAKE_INSTALL_PREFIX%/include;%INCLUDE%

REM Libraries
SET LIB=%CMAKE_INSTALL_PREFIX%/lib;%LIB%

REM This activates the VC2015 x86 tools for use.
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86

set BUILD_ROOT=%CWD%

REM This will configure zlib and then build it.
cd %ZLIB_BUILD%
cmake -DCMAKE_BUILD_TYPE="%CMAKEBUILDTYPE%" -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -G %GENERATOR% %SRCS_DIR%\zlib
devenv zlib.sln /build Debug /project INSTALL
REM devenv zlib.sln /build RelWithDebInfo /project INSTALL
devenv zlib.sln /build Release /project INSTALL

REM Remove the dynamic libraries -- we want to go static
REM and *never* risk getting the non-static variants.
del "%CMAKE_INSTALL_PREFIX%\bin\zlib.dll"
del "%CMAKE_INSTALL_PREFIX%\bin\zlibd.dll"
del "%CMAKE_INSTALL_PREFIX%\lib\zlib.lib"
del "%CMAKE_INSTALL_PREFIX%\lib\zlibd.lib"
cd %BUILD_ROOT%

REM libpng
cd %LIBPNG_BUILD%
cmake -DCMAKE_BUILD_TYPE="%CMAKEBUILDTYPE%" -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -DZLIB_LIBRARY_DEBUG="%CMAKE_INSTALL_PREFIX%\lib\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%CMAKE_INSTALL_PREFIX%\lib\zlibstatic.lib" -G %GENERATOR% -DPNG_DEBUG=OFF -DPNG_FRAMEWORK=OFF -DPNG_SHARED=OFF -DPNG_STATIC=ON %SRCS_DIR%\libpng\%PNG_INNER%
devenv libpng.sln /build Debug /project INSTALL
REM devenv libpng.sln /build RelWithDebInfo /project INSTALL
devenv libpng.sln /build Release /project INSTALL
cd %BUILD_ROOT%

REM freetype - we don't *need* BZip2 or Harfbuzz here
cd %FREETYPE_BUILD%
cmake -DCMAKE_BUILD_TYPE="%CMAKEBUILDTYPE%" -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%"  -DZLIB_LIBRARY_DEBUG="%CMAKE_INSTALL_PREFIX%\lib\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%CMAKE_INSTALL_PREFIX%\lib\zlibstatic.lib" -DPNG_PNG_INCLUDE_DIR="%CMAKE_INSTALL_PREFIX%\include" -DPNG_LIBRARY_DEBUG="%CMAKE_INSTALL_PREFIX%\lib\libpng16_staticd.lib" -DPNG_LIBRARY_RELEASE="%CMAKE_INSTALL_PREFIX%\lib\libpng16_static.lib" -G %GENERATOR%  %SRCS_DIR%\freetype2
devenv freetype.sln /build Debug /project INSTALL
REM devenv freetype.sln /build RelWithDebInfo /project INSTALL
devenv freetype.sln /build Release /project INSTALL
cd %BUILD_ROOT%

REM libogg
cd "%SRCS_DIR%\ogg\%OGG_INNER%\win32\VS2010"
MSBuild libogg_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Debug /p:UseEnv=true
MSBuild libogg_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Release /p:UseEnv=true
REM Copy out the binaries.
copy "Win32\Debug\libogg_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libogg_static_debug.lib"
copy "Win32\Release\libogg_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libogg_static.lib"
cd %BUILD_ROOT%

REM libvorbis
cd "%SRCS_DIR%\vorbis\%VORBIS_INNER%\win32\VS2010\libvorbis"
MSBuild libvorbis_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Debug /p:UseEnv=true
MSBuild libvorbis_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Release /p:UseEnv=true
REM Copy out the binaries.
copy "Win32\Debug\libvorbis_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libvorbis_static_debug.lib"
copy "Win32\Release\libvorbis_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libvorbis_static.lib"
cd %BUILD_ROOT%

REM libvorbisfile
cd "%SRCS_DIR%\vorbis\%VORBIS_INNER%\win32\VS2010\libvorbisfile"
MSBuild libvorbisfile_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Debug /p:UseEnv=true
MSBuild libvorbisfile_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Release /p:UseEnv=true
REM Copy out the binaries.
copy "Win32\Debug\libvorbisfile_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libvorbisfile_static_debug.lib"
copy "Win32\Release\libvorbisfile_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libvorbisfile_static.lib"
cd %BUILD_ROOT%

REM libtheora
cd "%SRCS_DIR%\theora\%THEORA_INNER%\win32\VS2008"
devenv /upgrade libtheora_static.sln
MSBuild libtheora_static.sln /p:PlatformToolset=v140 /t:build /p:configuration=Debug /p:UseEnv=true
MSBuild libtheora_static.sln /p:PlatformToolset=v140 /t:build /p:configuration=Release /p:UseEnv=true
REM Copy out the binaries.
copy "Win32\Debug\libtheora_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libtheora_static_debug.lib"
copy "Win32\Release\libtheora_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libtheora_static.lib"
cd %BUILD_ROOT%

REM FLAC
cd "%SRCS_DIR%\flac\src\libFLAC"
MSBuild libFLAC_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Debug /p:UseEnv=true
MSBuild libFLAC_static.vcxproj /p:PlatformToolset=v140 /t:build /p:configuration=Release /p:UseEnv=true
REM Copy out the binaries.
copy "objs\Debug\lib\libFLAC_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libFLAC_static_debug.lib"
copy "objs\Release\lib\libFLAC_static.lib" "%CMAKE_INSTALL_PREFIX%\lib\libFLAC_static.lib"
cd %BUILD_ROOT%

REM physfs (zlib only)
cd "%PHYSFS_BUILD%"
cmake -DCMAKE_BUILD_TYPE="%CMAKEBUILDTYPE%" -DCMAKE_DEBUG_POSTFIX="d" -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%"  -DZLIB_LIBRARY_DEBUG="%CMAKE_INSTALL_PREFIX%\lib\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%CMAKE_INSTALL_PREFIX%\lib\zlibstatic.lib" -DPHYSFS_ARCHIVE_7Z=ON -DPHYSFS_ARCHIVE_GRP=OFF -DPHYSFS_ARCHIVE_WAD=OFF -DPHYSFS_ARCHIVE_HOG=OFF -DPHYSFS_ARCHIVE_MVL=OFF -DPHYSFS_ARCHIVE_QPAK=OFF -DPHYSFS_BUILD_STATIC=ON -DPHYSFS_BUILD_SHARED=OFF -DPHYSFS_BUILD_TEST=OFF -G %GENERATOR% "%SRCS_DIR%\physfs\%PHYSFS_INNER%"
devenv PhysicsFS.sln /build Debug /project INSTALL
REM devenv PhysicsFS.sln /build RelWithDebInfo /project INSTALL
devenv PhysicsFS.sln /build Release /project INSTALL
cd %BUILD_ROOT%

REM dumb - don't do it
REM cd %DUMB_BUILD%
REM cmake -DBUILD_SHARED_LIBS=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -G %GENERATOR%  %SRCS_DIR%\dumb\%DUMB_INNER%\cmake
REM devenv libdumb.sln /build Debug /project INSTALL
REM devenv dumb.sln /build RelWithDebInfo /project INSTALL
REM devenv libdumb.sln /build Release /project INSTALL
REM cd %BUILD_ROOT%

REM Initiate Stage 3 ...
%COMSPEC% /k stage3.bat

REM We're done, return to the parent script...
exit