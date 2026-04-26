#!/usr/bin/env bash
set -euo pipefail

VERSION="0.3.10"

if command -v prek >/dev/null 2>&1; then
	installed="$(prek --version | awk '{print $NF}')"
	if [ "$installed" = "$VERSION" ]; then
		echo "prek $VERSION already installed"
		prek install
		exit 0
	fi
fi

if command -v cargo >/dev/null 2>&1; then
	cargo install \
		--locked \
		--git https://github.com/j178/prek \
		--tag "v${VERSION}" \
		prek
	export PATH="$HOME/.cargo/bin:$PATH"
	prek install
	exit 0
fi

echo "install pinned prek ${VERSION} from https://github.com/j178/prek/releases"
echo "or install Rust/cargo and rerun: bun run prek:install"
exit 1
