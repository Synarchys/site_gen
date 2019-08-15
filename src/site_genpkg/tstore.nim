
import json, tables, sequtils

# wrap json data for easier handling
type
  StoreObj* = object
    id*:  string
    `type`*: string
    data*: JsonNode # use nim root obj (?)
      
  ObjCollection = object
    current: string # id
    `type`: string
    ids: seq[string] # ids
  
  Store* = object
    data*: Table[string, StoreObj] # the whole data
    collection: Table[string, ObjCollection] # type, Storecollection
    

proc newStore*(): Store =
  result =  Store()
  result.data = initTable[string, StoreObj]()
  result.collection = initTable[string, ObjCollection]()
  

proc hasKey*(store: Store, key: string): bool =
  result = store.data.haskey key

  
proc getItem*(store: Store, id: string): StoreObj =
  result = store.data[id]
  

proc getCurrent*(store: Store, objType: string): StoreObj =
  let cid = store.collection[objType].current
  if cid != "":
    result = getItem(store, cid)


proc getCollection*(store: Store, objType: string): seq[StoreObj] =
  result = @[]
  if store.collection.haskey objType:
    for id in store.collection[objType].ids:
      result.add store.data[id]
    
    
proc setCurrent*(store: var Store, objType, id: string) =
  if store.collection.hasKey objType:
    store.collection[objType].current = id
  else:
    store.collection[objType] = ObjCollection(current: id)


proc setFieldValue*(store: var Store, id, field: string, value: JsonNode) =
  # TODO: handel data type
  if store.data.hasKey(id) and store.data[id].data.hasKey(field):
    store.data[id].data[field] = value


proc getFieldValue*(store: var Store, id, field: string): JsonNode =
  # TODO: handel data type
  if store.data.hasKey(id) and store.data[id].data.hasKey(field):
    result = store.data[id].data[field]
  

proc add*(store: var Store, objType: string, obj: JsonNode) =
  var so = StoreObj()
  if obj.haskey "id": so.id = obj["id"].getStr
  so.`type` = objType
  so.data = obj
  
  if not store.collection.haskey objType: store.collection[objType] = ObjCollection(`type`: objType)
  store.collection[objType].ids.add so.id
  
  store.data[so.id] = so
    
  
