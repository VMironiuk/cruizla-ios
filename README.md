# Cruizla-iOS
Cruizla iOS — offline maps and navigator for iOS based on MAPS.ME core.

## Cloning the project
Use `git clone --recursive` to clone the project and all submodules, or run `git submodule update --init --recursive` if you forgot to use `--recursive` option during cloning the project.

## Building the project
* Run `configure.sh` script from the root directory of the `Cruizla-iOS` project. This script runs `omim/configure.sh` script to configure the `omim` project and also applies `setup_omim.patch` to adjust the `omim` project to further using by the `Cruizla-iOS` project.
* Open `Cruizla/Cruizla.xcworkspace`.
* In Xcode select `Cruizla` scheme.
* Build the project.

## Updating submodules
Sometimes we need to update omim submodule to fetch fresh changes from MAPS.ME project. To do so, use next commands from the root project's directory (thinking about better approach):
* `git pull --recurse-submodules=yes`
* `git submodule update --recursive --remote`
* `cd omim`
* `git add .`
* `cd ..`
* `git add .`
* `git commit -m "Update submodules"`

## Coding style
* For Swift see [The Official raywenderlich.com Swift Style Guide.](https://github.com/raywenderlich/swift-style-guide)
* For Objective-C see [The official raywenderlich.com Objective-C Style Guide.](https://github.com/raywenderlich/objective-c-style-guide)
