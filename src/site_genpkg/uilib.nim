
import uielement
import uilib / input
export input


proc Form*(): UiElement =
  result = newUiElement(UiElementKind.kForm)
  
  
proc Link*(label: string, value: string = ""): UiElement =
  result = newUiElement(UiElementKind.kLink, label=label, events = @[UiEvent.click])
  result.value = value

  
proc NavSection*(navItems: seq[UiElement] = @[]): UiElement =
  result = newUiElement(UiElementKind.kNavSection)
  for ni in navItems:
    if not ni.hasAttribute "action":
      var item =  ni
      item.setAttribute("action", ni.value)
    if not ni.hasAttribute "action":
      var item =  ni
      item.setAttribute("action", ni.value)
      
  result.children = navItems
  

proc NavBar*(sections: seq[UiElement] = @[]): UiElement =
  result = newUiElement(UiElementKind.kNavBar)
  result.children = sections
  
  
proc Button*(label: string): UiElement =
  result = newUiElement(UiElementKind.kButton, label=label, events = @[UiEvent.click])
  

proc MenuItem*(label: string): UiElement =
  result = newUiElement(UiElementKind.kMenuItem, label=label, events = @[UiEvent.click])

  
proc Menu*(label="", menuItems: seq[UiElement]): UiElement =
  result = newUiElement(UiElementKind.kMenu)
  if label != "":
    result.value = label
  result.children = menuItems
