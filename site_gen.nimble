# Package

version       = "0.1.0"
author        = "Demian Florentin"
description   = "Website generator with nim and karax."
license       = "GPL-3.0"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["site_gen"]
installDirs   = @["baseapp"]

# Dependencies

requires "nim >= 0.19.0"
requires "https://github.com/demianfe/karax.git"
#requires "karax"

