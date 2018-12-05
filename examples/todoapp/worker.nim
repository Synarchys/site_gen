
import jsffi

proc postMessage(d: JsObject) {. importc: "postMessage" .}

var console {.importcpp, noDecl.}: JsObject 

console.log("Worker --> starting...")

var onmessage {.exportc.} =  proc(d: JsObject)  =
  console.log("Worker --> received a message from UI: ", d["data"]["message"])
  var data = newJsObject()
  data.data = "data"
  postMessage(data)
