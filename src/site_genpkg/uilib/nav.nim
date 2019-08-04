
import ../uielement


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
