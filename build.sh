# This file is a little complex, but it does some fairly basic things in
# fairly indirect ways.  The aim is to mimise the time it takes to
# update this file, with the aim being a single line being updated
# to fix issues in access (e.g. a download root, a version, etc.).

export CWD=`pwd`

# Paranoid copy
export __BUILD_ROOT__=$CWD


# detect windows
if [[ $OSTYPE =~ 'msys' ]]; then
	export OUT_ROOT="$CWD/out/win32"
	export BUILD_ROOT="$CWD/build/win32"
else
	export OUT_ROOT="$CWD/out/$OSTYPE"
	export BUILD_ROOT="$CWD/build/$OSTYPE"
fi
mkdir -p $OUT_ROOT
mkdir -p $BUILD_ROOT

export ALLEGRO_SOURCES="http://download.gna.org/allegro/allegro-unstable/5.1.13.1/allegro-5.1.13.1.tar.gz"
export ALLEGRO_ARCHIVE="allegro-5.1.tgz"
export ALLEGRO_INNER="allegro-5.1.13.1"
export ALLEGRO_BUILD="$BUILD_ROOT/allegro"

export ARCHIVE_DIR="$CWD/src/archives"
export SRCS_DIR="$CWD/src/extracted"
export GIT_DIR="$ARCHIVE_DIR/git"

export OGG_ARCHIVE="libogg.tgz"
export VORBIS_ARCHIVE="libvorbis.tgz"
export FLAC_ARCHIVE="flac.tar"
export FREETYPE_ARCHIVE="freetype2.tar"
export ZLIB_ARCHIVE="zlib.tar"
export LIBPNG_ARCHIVE="libpng.tgz"
export THEORA_ARCHIVE="libtheora.tgz"
export DUMB_ARCHIVE="libdumb.tar"

export OGG_BUILD="$BUILD_ROOT/ogg"
export VORBIS_BUILD="$BUILD_ROOT/vorbis"
export FLAC_BUILD="$BUILD_ROOT/flac"
export FREETYPE_BUILD="$BUILD_ROOT/freetype"
export ZLIB_BUILD="$BUILD_ROOT/zlib"
export LIBPNG_BUILD="$BUILD_ROOT/libpng"
export THEORA_BUILD="$BUILD_ROOT/theora"
export DUMB_BUILD="$BUILD_ROOT/dumb"

export XIPH_URI_ROOT="http://downloads.xiph.org/releases"
export XIPH_GIT_ROOT="http://git.xiph.org"
export SAVANNAH_GIT_ROOT="http://git.savannah.gnu.org/r"

# XIPH
export THEORA_SRCS="theora/libtheora-1.1.1.tar.gz"
export THEORA_INNER="libtheora-1.1.1"
export OGG_SRCS="ogg/libogg-1.3.2.tar.gz"
export OGG_INNER="libogg-1.3.2"
export VORBIS_SRCS="vorbis/libvorbis-1.3.5.tar.gz"
export VORBIS_INNER="libvorbis-1.3.5"

export FLAC_TAG="1.3.1"

export FREETYPE_REPOSITORY="freetype/freetype2.git"
export FREETYPE_TAG="VER-2-6-3"

export ZLIB_GIT="https://github.com/madler/zlib"
export ZLIB_DIR="zlib"

export DUMB_GIT="https://github.com/kode54/dumb"
export DUMB_DIR="dumb"
export DUMB_INNER="dumb"

export PNG_SRCS="libpng-1.6.21.tar.gz"
export PNG_INNER="libpng-1.6.21"
export PNG_SRC_ROOT="ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16"

# Create the directories
mkdir -p $ARCHIVE_DIR
mkdir -p $GIT_DIR
mkdir -p $SRCS_DIR

# This macro fetches (using curl).
FETCH() {
	if [ -f $ARCHIVE_DIR/$1 ]; then
		echo "$ARCHIVE_DIR/$1 exists."
	else
		echo "Downloading $1..."
		curl -s -o $ARCHIVE_DIR/$1 $2
	fi
}

# $1 is a "DIR/.git"
GITUPDATE() {
	# Get all branches
	git --git-dir $1 branch -r | grep -v HEAD | grep -v master | while read branch; do
		git --git-dir $1  branch --track ${branch##*/} $branch
	done

	# Get all remote data and tags
	git --git-dir $1 fetch --all
	git --git-dir $1 fetch --tags
	git --git-dir $1 pull --all
	git --git-dir $1 gc
}


# Uses a git repository which is kept stable (e.g. zlib)
GITFETCH() {
	if ! [ -f "$GIT_DIR/$1/.git/index" ]; then
		echo "Using git to clone the repository for creating archive '$2'"
		echo "Using remote repository '$2'"
		git clone --recursive $2 "$GIT_DIR/$1"
	else
		echo "$GIT_DIR/$1 exists, updating..."
	fi
	GITUPDATE "$GIT_DIR/$1/.git"
	git --git-dir "$GIT_DIR/$1/.git" archive --format=tar --output="$ARCHIVE_DIR/$3" master
}

# This macro downloads a git repository then archives its tag.
GITARCHIVE() {
	export FOLDERNAME="$GIT_DIR/$1"

	# clone if missing
	if ! [ -f "$FOLDERNAME/.git/index" ]; then
		echo "Using git to clone the repository for creating archive '$2'"
		echo "Using remote repository '$3'"
		git clone --recursive $3 $FOLDERNAME
	fi

	# Only force ourselves to suffer if we're missing the archive...
	if [ -f "$ARCHIVE_DIR/$2" ]; then
		echo "$ARCHIVE_DIR/$2 exists."
	else
		echo "$ARCHIVE_DIR/$2 does not exist, attempting to create..."
		GITUPDATE "$FOLDERNAME/.git"
		git --git-dir "$FOLDERNAME/.git" archive --format=tar --output="$ARCHIVE_DIR/$2" $4
	fi
}

# Only extracts *newer* files
EXTRACT() {
	mkdir -p $2
	tar -C $2 -xf "$ARCHIVE_DIR/$1" --keep-newer-files > /dev/null 2>&1
}

# Fetch Allegro here so we can go 2->3
FETCH $ALLEGRO_ARCHIVE $ALLEGRO_SOURCES

# Fetch stage
FETCH $OGG_ARCHIVE "$XIPH_URI_ROOT/$OGG_SRCS"
FETCH $VORBIS_ARCHIVE "$XIPH_URI_ROOT/$VORBIS_SRCS"
FETCH $THEORA_ARCHIVE "$XIPH_URI_ROOT/$THEORA_SRCS"
GITARCHIVE "flac" $FLAC_ARCHIVE "$XIPH_GIT_ROOT/flac.git" "$FLAC_TAG"
GITARCHIVE "freetype2" $FREETYPE_ARCHIVE "$SAVANNAH_GIT_ROOT/$FREETYPE_REPOSITORY" "$FREETYPE_TAG"
GITFETCH $ZLIB_DIR $ZLIB_GIT $ZLIB_ARCHIVE
FETCH $LIBPNG_ARCHIVE "$PNG_SRC_ROOT/$PNG_SRCS"

# dumb is currently a no-go, but we've got the pieces in play.
# https://github.com/kode54/dumb/issues/21
#GITFETCH $DUMB_DIR $DUMB_GIT $DUMB_ARCHIVE

# Source extraction
EXTRACT $ALLEGRO_ARCHIVE "$SRCS_DIR/allegro"
EXTRACT $OGG_ARCHIVE "$SRCS_DIR/ogg"
EXTRACT $VORBIS_ARCHIVE "$SRCS_DIR/vorbis"
EXTRACT $FLAC_ARCHIVE "$SRCS_DIR/flac"
EXTRACT $FREETYPE_ARCHIVE "$SRCS_DIR/freetype2"
EXTRACT $ZLIB_ARCHIVE "$SRCS_DIR/zlib"
EXTRACT $LIBPNG_ARCHIVE "$SRCS_DIR/libpng"
EXTRACT $THEORA_ARCHIVE "$SRCS_DIR/theora"
EXTRACT $DUMB_ARCHIVE "$SRCS_DIR/dumb"

# Setup build ...
mkdir -p $ALLEGRO_BUILD
mkdir -p $OGG_BUILD
mkdir -p $VORBIS_BUILD
mkdir -p $FLAC_BUILD
mkdir -p $FREETYPE_BUILD
mkdir -p $ZLIB_BUILD
mkdir -p $LIBPNG_BUILD
mkdir -p $THEORA_BUILD
mkdir -p $DUMB_BUILD

# CMake install...
export CMAKE_INSTALL_PREFIX="$OUT_ROOT/cmake_install"
mkdir -p $CMAKE_INSTALL_PREFIX

export CMAKEBUILDTYPE="Debug;Release;RelWithDebInfo"

# Some housekeeping
mkdir -p "$CMAKE_INSTALL_PREFIX/bin"

# ext src dest
XCOPY() {
	cd $2
	tar -cf - `find . -name "*.$1" -print` 2>/dev/null | ( cd $3 && tar xBf - ) 2>/dev/null
	cd $CWD
}

# ogg includes
mkdir -p "$CMAKE_INSTALL_PREFIX/include/ogg"
XCOPY h "$SRCS_DIR/ogg/$OGG_INNER/include/ogg" "$CMAKE_INSTALL_PREFIX/include/ogg"
#XCOPY hpp "$SRCS_DIR/ogg/$OGG_INNER/include/ogg" "$CMAKE_INSTALL_PREFIX/include/ogg"

# Vorbis and Vorbis file includes
mkdir -p "$CMAKE_INSTALL_PREFIX/include/vorbis"
XCOPY h "$SRCS_DIR/vorbis/$VORBIS_INNER/include/vorbis" "$CMAKE_INSTALL_PREFIX/include/vorbis"
#XCOPY hpp "$SRCS_DIR/vorbis/$VORBIS_INNER/include/vorbis" "$CMAKE_INSTALL_PREFIX/include/vorbis"

# FLAC
mkdir -p "$CMAKE_INSTALL_PREFIX/include/FLAC"
XCOPY h "$SRCS_DIR/flac/include/FLAC" "$CMAKE_INSTALL_PREFIX/include/FLAC"

# theora
mkdir -p "$CMAKE_INSTALL_PREFIX/include/theora"
XCOPY h "$SRCS_DIR/theora/$THEORA_INNER/include/theora" "$CMAKE_INSTALL_PREFIX/include/theora"

# Building...
if [[ $OSTYPE =~ 'msys' ]]; then
	# If all goes well it'll build and we'll love it.
	$COMSPEC //k stage2.bat
else
	sh stage2.sh
fi

echo "# This file was generated by the Allegro dependencies build script" > "`pwd`/AllegroDependencies.cmake"
echo "# Last Updated Datestamp: `date`" >> "`pwd`/AllegroDependencies.cmake"

if [[ $OSTYPE =~ 'msys' ]]; then
	$COMSPEC //k includes.bat
else
	echo "include(\"`pwd`/AllegroDependenciesWin32.cmake\")" >> "`pwd`/AllegroDependencies.cmake"
	#echo "include(\"`pwd`/AllegroDependenciesGeneric.cmake\")" >> "`pwd`/AllegroDependencies.cmake"
	echo "include_directories(\"$CMAKE_INSTALL_PREFIX\")" >> "`pwd`/AllegroDependencies.cmake"
fi

# Generate Generic if missing.
if ! [ -f "`pwd`/AllegroDependenciesGeneric.cmake" ]; then
	touch "`pwd`/AllegroDependenciesGeneric.cmake"
fi

# Generate Win32 if missing.
if ! [ -f "`pwd`/AllegroDependenciesWin32.cmake" ]; then
	touch "`pwd`/AllegroDependenciesWin32.cmake"
fi