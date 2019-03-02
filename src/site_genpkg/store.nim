import json

# general store procs

proc getItem*(appState:JsonNode, id: string): JsonNode =
  if appState.hasKey("store") and appState["store"].haskey("data"):
    result = appState["store"]["data"][id]


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

    
proc getList*(appState:JsonNode, objType: string): JsonNode =
  # returns a jsnode of kind array
  if appState["store"].haskey("objects") and appState["store"]["objects"].haskey(objType):
    result = appState["store"]["objects"][objType]["list"]
