
include karax / prelude 
import karax / prelude

import sugar, json

proc Content*(def: JsonNode): VNode =
  result = buildHtml(tdiv()):
    p:
      text "Site Loaded."
