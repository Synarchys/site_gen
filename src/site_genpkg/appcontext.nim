
import json, tables, tstore, uielement

type
  MessageKind* = enum
    normal, success, warning, error, primary
    
  AppMessage* = ref object
    tilte*, content*: string
    kind*: MessageKind

  Request* = ref object
    queryString*: OrderedTable[string, string]

  AppContext* = ref object # of RootObj
    state*: JsonNode
    components*: Table[string, proc(ctxt: AppContext, uidef, payload: JsonNode): JsonNode]
    uicomponents*: Table[string, proc(ctxt: AppContext): UiElement]
    actions*: Table[cstring, proc(payload: JsonNode)]
    ignoreField*: proc(field: string): bool # proc that returns true if the field should be ignored
    renderer*: proc (payload: JsonNode)
    labelFormat*: proc(text: string): string
    navigate*: proc(ctxt: var AppContext, payload: JsonNode, viewid: string): JsonNode # returns the new payload
    store*: Store
    request*: Request
    messages*: seq[AppMessage]
      
  App* = ref object 
    id*: string
    title*: string
    layout*: seq[UiElement] # header, menu, body, footer
    state*: string
    ctxt*: AppContext
    wb*: WebBuilder
    

proc newMessage*(content: string, kind: MessageKind): AppMessage =
  result = AppMessage()
  result.content = content
  result.kind = kind


proc newMessage*(content: string, title=""): AppMessage =
  result = newMessage(content, MessageKind.normal)

  
proc newSuccessMessage*(content: string, title=""): AppMessage =
  result = newMessage(content, MessageKind.success)

  
proc newWarningMessage*(content: string, title=""): AppMessage =
  result = newMessage(content, MessageKind.warning)

  
proc newErrorMessage*(content: string, title=""): AppMessage =
  result = newMessage(content, MessageKind.error)
  

proc newPrimaryMessage*(content: string, title=""): AppMessage =
  result = newMessage(content, MessageKind.primary)


proc addMessage*(ctxt: AppContext, kind: string, content: string,  title="") =
  var msg: AppMessage  
  case $kind
  of "success":
    msg = newSuccessMessage(content, title)
  of "warning":
    msg = newWarningMessage(content, title)
  of "error":
    msg = newErrorMessage(content, title)
  of "primary":
    msg = newPrimaryMessage(content, title)
  else:
    msg = newMessage(content, title)  
  ctxt.messages.add msg

  
proc addMessage*(ctxt: AppContext, m: AppMessage) =
  ctxt.messages.add m
