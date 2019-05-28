
import json, tables, sequtils, times, strutils
import ../ui_utils, ./uicomponent

proc UIMessages*(appState, def: JsonNode, data: JsonNode = nil): JsonNode =
  # data message:
  # messge type: success, error, warning
  # message title
  # message content
  let templates = appState["templates"]
  result = %*{"ui-type": %"div", "children": %[]}
  result["id"] = %"sitegen_messages"
  var msgType = "alert alert-"
  if not data.isNil:
    if data.hasKey "title":
      result["children"].add %*{"ui-type": %"h4",
                                 "attributes": %*{"class": %"alert-heading"},
                                 "children": %[{"ui-type": %"#text", "text": data["title"]}]}

    case data["type"].getStr
    of "success": 
      msgType = msgType & "success"
    of "warning":
       msgType = msgType & "warning"
    of "error":
      msgType = msgType & "danger"
    else:
      msgType = msgType & "secondary"
    
    msgType = msgType & " alert-dismissible fade show"
    
    result["attributes"] = %*{"class": %msgType, "role": %"alert"}
    var b = copy templates["button"]
    b["attributes"] = %*{ "class": %"close",  "aria-label": %"Close" }
    
    b["children"] = %[%*{ "ui-type": %"span",
                          "attributes": %*{"aria-hidden": %"true"},
                          "children": %[{"ui-type": %"#text", "text": %"x" }]
    }]

    b["model"]  = %"messages"
    b["name"]   = %"nav"
    b["events"] = %"onclick"
    result["children"].add %*{ "ui-type": %"text", "text": data["text"] }
    result["children"].add b
