
import ../uielement

proc Link*(label: string, value: string = ""): UiElement =
  result = newUiElement(UiElementKind.kLink, label=label, events = @[UiEventKind.click])
  result.value = value
