
import ../uielement
import ../uibuild/button
  
proc Button*(label: string): UiElement =
  result = newUiElement(UiElementKind.kButton, label=label, events = @[UiEventKind.click])
  result.builder = buildButton
