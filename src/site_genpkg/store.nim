import json

# general store procs

proc getItem*(appState: JsonNode, id: string): JsonNode =
  if appState.hasKey("store") and appState["store"].haskey("data"):
    if appState{"store", "data"}.hasKey id:
      result = appState{"store", "data", id}


proc getCurrent*(appState:JsonNode, objType: string): JsonNode =
  if appState["store"].haskey("objects") and
     appState["store"]["objects"].haskey(objType) and
    appState["store"]["objects"][objType].hasKey("current"):
    let id = appState["store"]["objects"][objType]["current"].getStr
    if id != "":
      result = appState["store"]["data"][id]


proc setCurrent*(appState:JsonNode, objType, id: string) =
  if appState["store"].haskey("objects") and appState["store"]["objects"].haskey(objType):
    appState["store"]["objects"][objType]["current"] = %id


proc setFieldValue*(appState:JsonNode, objType, field, value: string) =
  var c = getCurrent(appState, objType)
  c[field] = %value

    
proc getList*(appState:JsonNode, objType: string): JsonNode =
  # returns a jsnode of kind array
  if appState["store"].haskey("objects") and appState["store"]["objects"].haskey(objType):
    result = appState["store"]["objects"][objType]["list"]


proc addToStore*(appState, obj: JsonNode, resource: string) =
  obj["type"] = %resource
  appState{"store", "data", obj["id"].getStr} = obj
  # add to the objects
  if not appState["store"].hasKey "objects":
    appState{"store", "objects"} = %*{}
    if not appState{"store", "objects"}.hasKey resource:
      appState{"store", "objects", resource} = %*{"current": %"", "list": %[]}
  appState{"store", "objects", resource, "list"}.add obj["id"]
