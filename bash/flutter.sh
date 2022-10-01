# !/bin/bash

# -----------------------------------------------------------------------------
# WIP
# -----------------------------------------------------------------------------

root_dirs=$(cat <<EOF
	assets assets/fonts assets/images assets/l10n
	lib lib/src
EOF
)

base_dirs=$(cat <<EOF
	config
	constants
	models
	providers
	services
	utils/helpers utils/mixins
	widgets
	modules
EOF
)

feature_dirs=$(cat <<EOF
	modules/feature-a
	modules/feature-b
EOF
)

function init_app() {
	path=$1
	# mkdir -p $root_dirs
	for dir in $base_dirs; do
		mkdir -p "lib/src/$dir"
		echo '' > "lib/src/$dir/.gitkeep"
	done

	for dir in $feature_dirs; do
		mkdir -p "lib/src/$dir"
		for base_dir in $base_dirs; do
			mkdir -p "lib/src/$dir/$base_dir"
			echo '' > "lib/src/$dir/$base_dir/.gitkeep"
		done
	done
}

# -----------------------------------------------------------------------------
# New Flutter application
# -----------------------------------------------------------------------------
function create_app() {
	path=${1:-'app'}
	flutter create ${path}
	cd ${path}
	init_app ${path}
}

create_app $1
