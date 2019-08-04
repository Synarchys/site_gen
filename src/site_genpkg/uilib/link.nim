
import ../uielement

proc Link*(label: string, value: string = ""): UiElement =
  result = newUiElement(UiElementKind.kLink, label=label, events = @[UiEvent.click])
  result.value = value
