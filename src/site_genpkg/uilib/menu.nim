
import ../uielement

proc MenuItem*(label: string): UiElement =
  result = newUiElement(UiElementKind.kMenuItem, label=label, events = @[UiEventKind.click])

  
proc Menu*(label="", menuItems: seq[UiElement]): UiElement =
  result = newUiElement(UiElementKind.kMenu)
  if label != "":
    result.value = label
  result.children = menuItems
