
import json, tables, sequtils
import appcontext

        
# general store procs
proc hasId*(ctxt: AppContext, id: string): bool =
  return ctxt.state{"store", "data"}.haskey id


proc getItem*(ctxt: AppContext, id: string): JsonNode =
  if ctxt.state.haskey("store") and ctxt.state["store"].haskey("data"):
    if ctxt.state{"store", "data"}.hasKey id:
      result = ctxt.state{"store", "data", id}


proc getCurrent*(ctxt: AppContext, objType: string): string =
  if ctxt.state["store"].haskey("objects") and
     ctxt.state["store"]["objects"].haskey(objType) and
     ctxt.state["store"]["objects"][objType].hasKey("current"):
    result = ctxt.state{"store", "objects", objType, "current"}.getStr
    # if id != "":
    #   result = ctxt.state["store"]["data"][id].getStr


proc setCurrent*(ctxt: AppContext, objType, id: string) =
  if ctxt.state["store"].haskey("objects") and ctxt.state["store"]["objects"].haskey(objType):
    ctxt.state{"store", "objects", objType, "current"} = %id


proc setFieldValue*(ctxt: AppContext, id, field: string, value: JsonNode) =
  # var c = getItem(ctxt, id)
  # c[field] = value
  if ctxt.state{"store", "data"}.haskey id:
    ctxt.state{"store", "data", id, field} = value
  else:
    echo "Error: setFieldValue there is no item for id " & id 


proc setFieldValue*(ctxt: AppContext, id, field, value: string) =
  # var c = getItem(ctxt, id)
  # ctxt.
  # c[field] = %value
  if ctxt.state{"store", "data"}.haskey id:
    ctxt.state{"store", "data", id, field} = %value
  else:
    echo "Error: setFieldValue there is no item for id " & id 


proc getFieldValue*(ctxt: AppContext, id, field: string): JsonNode =
  # var c = getItem(ctxt, id)
  # result = c[field]
  if ctxt.state{"store", "data"}.haskey id:
    result = ctxt.state{"store", "data", id, field}
  else:
    echo "Error: getFieldValue there is no item for id " & id 


proc getTypeIds*(ctxt: AppContext, objType: string): seq[string] =
  # returns a jsnode of kind array
  #result = %[]
  if ctxt.state["store"].haskey("objects") and ctxt.state["store"]["objects"].haskey(objType):
    if not ctxt.state{"store", "objects", objType, "list"}.isNil:
      result = ctxt.state{"store", "objects", objType, "list"}.to(seq[string])


proc getItems*(ctxt: AppContext, ids: seq[string]): seq[JsonNode] =
  # helper proc that returns a list of entities
  result = @[]
  for objId in ids:
    result.add getItem(ctxt, objId)


proc getList*(ctxt: AppContext, objType: string): JsonNode {.deprecated.} =
  # returns a jsnode of kind array
  #result = %[]
  if ctxt.state["store"].haskey("objects") and ctxt.state["store"]["objects"].haskey(objType):
    result = ctxt.state["store"]["objects"][objType]["list"]


proc getModelList*(ctxt: AppContext, ids: JsonNode): JsonNode {.deprecated.} =
  # helper proc that returns a list of entities
  result = %[]
  for objId in ids:
    result.add getItem(ctxt, objId.getStr)


proc addToStore*(ctxt: AppContext, obj: JsonNode, objType: string) =
  obj["type"] = %objType
  # store to data
  ctxt.state{"store", "data", obj["id"].getStr} = obj
  # add to the objects
  if not ctxt.state["store"].hasKey "objects":
    ctxt.state{"store", "objects"} = %*{}
                                       
  if not ctxt.state{"store", "objects"}.hasKey objType:
    ctxt.state{"store", "objects", objType} = %*{"current": %"", "list": %[]}

  if ctxt.state{"store", "objects", objType, "list"}.to(seq[string]).count(obj["id"].getStr) == 0:
    # add only if it does not exists.
    ctxt.state{"store", "objects", objType, "list"}.add obj["id"]


proc removeFromStore*(ctxt: AppContext, objType, id: string) =
  # get the item by id
  echo id
  ctxt.state{"store", "data"}.delete id
  # filter out
  var objList = copy ctxt.state{"store", "objects", objType, "list"}
  ctxt.state{"store", "objects", objType, "list"} =
    %objList.to(seq[string]).filter(proc(i: string): bool = i != id)
  
