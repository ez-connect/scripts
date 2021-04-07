#!/bin/bash
#
# Build a Hugo site
#

# Constants
readonly BUILD_DIR='public' # default Hugo output dir
readonly USE_GZIP=0

# Help
function help() {
  echo 'Usage: ./hugo-build.sh [-z|--gzip]'
  echo 'Build a hugo site'
  echo
  echo 'Options:'
  echo -e '  -z, --gzip \t output a single file site.tar.gz, default 0'
  echo -e '  -h, --help \t print this help'
}

# Hugo build
# Option: `-z|--gzip` to create `site.tar.gz` file, default 0
build() {
  dir='public' # default Hugo output dir

  # Remove build dir
  if [ -d "${dir}" ]; then
    rm -rf "${dir}"
  fi

  # Build
  hugo --gc --minify

  echo
  du -h --max-depth=0 "${dir}"

  # Compress
  gzip=$1
  if [ ${gzip} == 1 ]; then
    file='site.tar.gz'

    pushd "${dir}"
    tar -czf "${file}" *
    du -h "${file}"
    popd
  fi
}


# Default values of arguments
gzip=${USE_GZIP}

# Loop through arguments and process them
for arg in "$@"
do
  case $arg in
    # -m|--minify)
    #   minify=1
    #   shift;;

    -z|--gzip)
      gzip=1
      shift;;

    -h|--help)
      help
      exit;;
  esac
done

build ${gzip}
