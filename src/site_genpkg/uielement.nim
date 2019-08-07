
import sequtils, tables, json

import karax / [vdom, kdom]
    
type
  UiElementKind* = enum
    kComponent, kLayout, kHeader, kFooter, kBody, kButton, kDropdopwn, kIcon,
    kLabel, kText, kMenu, kMenuItem, kNavBar, kNavSection, kLink,
    kInputText, kList, kListItem, kForm, kCheckBox

  UiElement* = ref UiElementObj

  UiEventKind* = enum
    click, keydown, keyup

  UiEvent* = object
    kind*: UiEventKind
    targetKind*: EventKind
    handler*: proc(uiev: uielement.UiEvent, el: UiElement, viewid: string): proc(ev: Event, n: VNode)
  
  UiElementObj* = object
    id*: string
    kind*: UiElementKind
    label*: string
    value*: string
    attributes*: Table[string, string]
    children*: seq[UiElement]
    events*: seq[UiEvent]
    render*: proc(): UiElement # redraws the ui element.
    
    
proc addChild*(parent: var UiElement, child: UiElement) =
  parent.children.add child

  
# proc addLabel*(parent: var UiElement, label: string) =
#   var txt = UiElement()
#   txt.kind = UiElementKind.kLabel
#   txt.value = label
#   parent.addChild txt

# proc setLabel*(parent: var UiElement, label: string) =
#   if parent.children.len == 0:
#     addLabel(parent, label)
#   else:    
#     for child in parent.children.items:
#       var c = child
#       if c.kind == UiElementKind.kText:
#         c.label = label
#         break


proc hasAttribute*(el: UiElement, attr: string): bool =
  result = el.attributes.haskey attr
  

proc getAttribute*(el: UiElement, key: string): string =
  if el.hasAttribute key:
    result = el.attributes[key]

  
proc setAttribute*(parent: var UiElement, key, value: string) =
  # TODO: handle basic types
  ## if it does not exist it is added
  parent.attributes[key] = value


proc removeAttribute*(parent: var UiElement, key: string) =
  if parent.attributes.haskey(key):
    parent.attributes.del key
  

proc addEvent*(parent: var UiElement, event: UiEvent) =
  ## if it does not exist it is added
  if not parent.events.contains event:
    parent.events.add event


proc newUiElement*(): UiElement =
   result = UiElement()


proc newUiElement*(kind: UiElementKind): UiElement =
  result = newUiElement()
  result.kind = kind


proc newUiElement*(kind: UiElementKind, id, label: string): UiElement =
  result = newUiElement()
  result.kind = kind
  if label != "":
    result.label = label     
  if id != "":
    result.id = id


proc newUiElement*(kind: UiElementKind, id, label="", events: seq[UiEventKind]): UiElement =
  result = newUiElement(kind)
  if label != "":
    result.label = label

  if id != "":
    result.id = id
  for evk in events:
    var ev = UiEvent()
    ev.kind = evk
    result.events.add ev
  #result.events = events
  
  
proc newUiElement*(kind: UiElementKind, label="",
                   attributes:Table[string, string], events: seq[UiEventKind]): UiElement =
    
  result = newUiElement(kind, label = label, events = events)
  result.kind = kind
  result.attributes = attributes    

