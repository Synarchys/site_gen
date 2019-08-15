
import ../uielement
import ../uibuild / input


proc InputText*(id, label = ""): UiElement =
  result = newUiElement(UiElementKind.kInputText, events = @[UiEventKind.keyup])
  result.setAttribute("type", "text")
  result.label = label
  result.id = id
  result.builder = buildInputText
