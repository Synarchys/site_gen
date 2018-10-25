
include karax / prelude 
import karax / [prelude, kdom]

import json

proc Header*(def: JsonNode):Vnode =
  result = buildHtml(tdiv()):
    header(class="masthead"):
      tdiv(class="container"):
        tdiv(class="intro-text"):
          img(class="mobil", src="image logo", alt=def["alternative"].getStr)
