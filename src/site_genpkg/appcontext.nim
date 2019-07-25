
import json, tables

type
  AppContext* = ref object # of RootObj
    state*: JsonNode
    components*: Table[string, proc(ctxt: AppContext, uidef, payload: JsonNode): JsonNode]
    actions*: Table[cstring, proc(payload: JsonNode)]
    ignoreField*: proc(field: string): bool # proc that returns true if the field should be ignored
    renderer*: proc (payload: JsonNode)
    labelFormat*: proc(text: string): string
    navigate*: proc(ctxt: var AppContext, payload: JsonNode, viewid: string): JsonNode # returns the new payload
