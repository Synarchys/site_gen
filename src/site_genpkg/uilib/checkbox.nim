
import ../uielement


proc CheckBox*(id, label = ""): UiElement =
  result = newUiElement(UiElementKind.kCheckBox, events = @[UiEvent.click])
  result.setAttribute("type", "checkbox")
  result.label = label
  result.id = id
