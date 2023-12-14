# Julti-OBS-Link
An OBS Script to link OBS to [Julti](https://github.com/DuncanRuns/Julti), a Minecraft speedrunning tool.

## Development

Included are a few python scripts to build, configure, and help development of the script:
- Run `download_obs_sources.py` to generate obs sources. The downloaded file is in `.gitignore`.
- Run `build.py` to build the final script.
- Run `build_loop.py` to rebuild the final script every time a change is made (useful for actively developing and testing).
- Output location can be configured in `properties.py`, but make sure not to include changes to that location in a commit.
- A `private_properties.py` file can be created for developer specific properties. Private properties are in `.gitignore`, meaning this extra output location can be specific to your computer. If the file does not exist, no private properties are used. `private_properties.py` variables:
  - `extra_output_location` - A path to an extra output location that the build scripts will output to.
  - `only_do_extra` - A boolean variable that means only the extra output location will be used (if enabled).