
import uielement


proc Link*(text: string): UiElement =
  result = newUiElement(UiElementKind.kLink, text=text, events = @["onclick"])

  
proc NavSection*(navItems: seq[UiElement] = @[]): UiElement =
  result = newUiElement(UiElementKind.kNavSection)
  result.children = navItems
  

proc NavBar*(sections: seq[UiElement] = @[]): UiElement =
  result = newUiElement(UiElementKind.kNavBar)
  result.children = sections
  
  
proc Button*(text: string): UiElement =
  result = newUiElement(UiElementKind.kButton, text=text, events = @["onclick"])
  

proc MenuItem*(text: string): UiElement =
  result = newUiElement(UiElementKind.kMenuItem, text=text, events = @["onclick"])

  
proc Menu*(text="", menuItems: seq[UiElement]): UiElement =
  result = newUiElement(UiElementKind.kMenu)
  if text != "":
    result.value = text
  result.children = menuItems

