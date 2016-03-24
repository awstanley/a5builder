@echo off
REM This file uses the known paths/values of the build (stage 2)
REM to handle building Allegro.

cd %ALLEGRO_BUILD%
cmake -DCMAKE_BUILD_TYPE="%CMAKEBUILDTYPE%" -DCMAKE_DEBUG_POSTFIX="_debug" -DCMAKE_INSTALL_PREFIX="%CMAKE_INSTALL_PREFIX%" -DWANT_TESTS=OFF -DWANT_DEMO=OFF -DWANT_DOCS=OFF -DWANT_DOCS_HTML=OFF -DWANT_DOCS_MAN=OFF -DWANT_DOCS_INFO=OFF -DWANT_DOCS_PDF=OFF -DWANT_DOCS_PDF_PAPER=OFF -DZLIB_LIBRARY_RELEASE="%CMAKE_INSTALL_PREFIX%\lib\zlibstatic.lib"  -DZLIB_LIBRARY="%CMAKE_INSTALL_PREFIX%\lib\zlibstatic.lib" -DZLIB_LIBRARY_DEBUG="%CMAKE_INSTALL_PREFIX%\lib\zlibstaticd.lib" -DFLAC_STATIC=ON -DWANT_EXAMPLES=OFF -DWANT_MONOLITH=ON -DSHARED=OFF -DPHYSFS_INCLUDE_DIR="%SRCS_DIR%\physfs\%PHYSFS_INNER%" %SRCS_DIR%\allegro\%ALLEGRO_INNER%
devenv ALLEGRO.sln /build Debug /project INSTALL
REM devenv ALLEGRO.sln /build RelWithDebInfo /project INSTALL
devenv ALLEGRO.sln /build Release /project INSTALL
cd %BUILD_ROOT%

REM Now generate the include using fixed paths...

set AllegroDeps="%BUILD_ROOT%\AllegroDependenciesWin32.cmake"

REM TODO: Fix ordering

echo # Allegro Win32 Include > %AllegroDeps%
echo # This file is generated by the build scripts >> %AllegroDeps%
echo if(${WIN32}) >> %AllegroDeps%


echo 	macro(LINK_ALLEGRO BINARY_NAME) >> %AllegroDeps%

REM Allegro itself
echo 		set_target_properties(${BINARY_NAME} PROPERTIES COMPILE_DEFINITIONS "ALLEGRO_STATICLINK") >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/allegro_monolith-static_debug.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/allegro_monolith-static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/freetyped.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/freetype.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/libFLAC_static_debug.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/libFLAC_static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/libogg_static_debug.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/libogg_static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/libpng16_staticd.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/libpng16_static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/libtheora_static_debug.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/libtheora_static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/libvorbisfile_static_debug.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/libvorbisfile_static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/libvorbis_static_debug.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/libvorbis_static.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

REM physfs (static)
echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/physfsd.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/physfs.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

REM zlib
echo 		target_link_libraries(${BINARY_NAME} >> %AllegroDeps%
echo 			debug "%CMAKE_INSTALL_PREFIX%/lib/zlibstaticd.lib" >> %AllegroDeps%
echo 			optimized "%CMAKE_INSTALL_PREFIX%/lib/zlibstatic.lib" >> %AllegroDeps%
echo 		) >> %AllegroDeps%

REM win32 specific magic
echo 		find_package(OpenGL REQUIRED) >> %AllegroDeps%
echo 		include_directories(${OPENGL_INCLUDE_DIR}) >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} ${OPENGL_LIBRARIES}) >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} "winmm.lib") >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} "Psapi.lib") >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} "Shlwapi.lib") >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} "Gdi32.lib") >> %AllegroDeps%
echo 		target_link_libraries(${BINARY_NAME} "Gdiplus.lib") >> %AllegroDeps%
echo 	endmacro() >> %AllegroDeps%
echo endif() >> %AllegroDeps%



REM We're done, return to the parent script...
exit