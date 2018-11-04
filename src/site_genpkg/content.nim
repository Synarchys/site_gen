
include karax / prelude 
import karax / [prelude, vstyles]
import json

import cards, form

proc Content*(def: JsonNode): VNode =
  let children  = def["children"]
  result = buildHtml(section(class="bg-white")):
    tdiv(class="container"):
      tdiv(class="row"):
        for child in children:
          tdiv(class="col-md"):
            if child.hasKey("card"):
              Card(child["card"])
            if child.hasKey("form"):
              Form(child["form"])
