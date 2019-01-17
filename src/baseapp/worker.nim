# base main worker

import json, jsffi, tables, sequtils, strutils
import site_genpkg / [ui_utils, worker_utils]
import jsonflow, uuidjs


var
  ui: JsonNode # global ui sate in memory

# need to react to data changes
var dataListeners = initTable[cstring, cstring]()


worker:
  # event handlers
  EventHandlers:
    proc some_component_onkeyup(payload: JsonNode) =
      echo "processing event handler"




