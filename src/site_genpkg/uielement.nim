
import sequtils, tables
import appcontext


type
  UiElementKind* = enum
    kLayout, kHeader, kFooter, kBody, kButton, kDropdopwn, kIcon,
    kText, kLabel, kMenu, kMenuItem, kNavBar, kNavSection, kLink, 
    kList, kListItem
    

type
  UiElement* = object of RootObj
    id*: string
    kind*: UiElementKind
    value*: string
    # data*: ref RootObj # point to a model object ?
    attributes*: Table[string, string]
    children*: seq[UiElement]
    events*: seq[string]
    ctxt*: ref AppContext # reference to context
    

type
  App* = object of RootObj
    id*: string
    title*: string
    layout*: seq[UiElement] # header, menu, body, footer
    state*: string
    ctxt*: AppContext
    
  
proc addChild*(parent: var UiElement, child: UiElement) =
  parent.children.add child


proc addText*(parent: var UiElement, text: string) =
  var txt = UiElement()
  txt.kind = UiElementKind.kText
  txt.value = text
  parent.addChild txt


proc setText*(parent: var UiElement, text: string) =
  if parent.children.len == 0:
    addText(parent, text)
  else:
    
    for child in parent.children.items:
      var c = child
      if c.kind == UiElementKind.kText:
        c.value = text
        break

  
proc setAttribute*(parent: var UiElement, key, value: string) =
  # TODO: handle basic types
  ## if it does not exist it is added
  parent.attributes[key] = value


proc removeAttribute*(parent: var UiElement, key: string) =
  if parent.attributes.haskey(key):
    parent.attributes.del key
  

proc addEvent*(parent: var UiElement, event: string) =
  ## if it does not exist it is added
  if not parent.events.contains event:
    parent.events.add event


proc newUiElement*(): UiElement =
   result = UiElement()


proc newUiElement*(kind: UiElementKind): UiElement =
  result = newUiElement()
  result.kind = kind


proc newUiElement*(kind: UiElementKind, text: string): UiElement =
  result = newUiElement()
  result.kind = kind
  result.value = text

proc newUiElement*(kind: UiElementKind, text="", events: seq[string]): UiElement =
  result = newUiElement(kind)
  
  if text != "":
    result.value = text
    
  result.events = events
  
   
proc newUiElement*(kind: UiElementKind, text="",
                   attributes:Table[string, string], events: seq[string]): UiElement =
  result = newUiElement(kind, text=text, events= events)
  result.kind = kind
  result.attributes = attributes    

