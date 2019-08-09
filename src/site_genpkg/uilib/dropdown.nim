

import ../uielement

proc DropdownItem*(label: string): UiElement =
  result = newUiElement(UiElementKind.kDropdownItem, label=label, events = @[UiEventKind.click])

  
proc Dropdown*(): UiElement =
  result = newUiElement(UiElementKind.kDropdown)


proc Dropdown*(dropdownItems: seq[UiElement]): UiElement =
  result = newUiElement(UiElementKind.kDropdown)
  result.children = dropdownItems
