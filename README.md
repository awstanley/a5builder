# Allegro 5.1 dependencies scripts.

This is a repository containing scripts to get stable versions of the Allegro dependencies downloaded and compiled.

Where tags are available on git repositories the git repository and a local archive command is used; where tags aren't available but compatible archives are (i.e. `tar.gz` or `tar.bz2`), the archives are used.  In some places the archive is copied anyway to avoid huge updates in the future (e.g. FreeType 2).

`This currently ONLY suports Windows via Visual Studio; I'm too lazy to get the other part updated during development, poke me (file an issue) if you need it and can't work it out yourself.`

## Requirements

All platforms will require CMake as it is required by Allegro.

### Windows specific
  * Visual Studio 2015 (Community is fine);
  * `Git for Windows` (available as part of the VS2015 install).

## Building

Open your terminal (or `Git Bash for Windows`) and enter `sh build.sh`.

Since Windows is harder to get up and running than other platforms, it was done first.  Other platforms are on the todo list.

## Notes

  * This builds static copies of everything that, by licence, is better to have static for your own sanity.

### How this works

This script uses standard commandline utilities (for Windows these are all provided by the `Git for Windows` install).  To keep things crossplatform the `xz` extension *has* to be avoided, and so git cloning and archiving is used to bypass this.  While this is sort of ugly, it does come with the bonus benefit of providing archived copies of the code to move around -- just copy the source file, network mount this, or whatever.

Internally it uses a batch script (and when I get around to it a bash script) to make and install.  For Windows, there is no `/usr/local`, so it installs into a cmake_install directory within the `out` path created.  For other platforms I have a similar idea in mind to prevent mixing/clobbering things we don't want to break.

### Exclusions
  * `libjpeg` is excluded as I don't personally use JPEGs.  It can be added from various sources, but again, it isn't included here;
  * `OpenAL` is excluded.  OS X has it anyway, Windows and Linux don't explicitly need it.  You can add it, but I'm skipping it because it's LGPL and as a result will require fiddling with binaries (where nothing else does).