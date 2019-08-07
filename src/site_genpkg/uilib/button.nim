
import ../uielement

  
proc Button*(label: string): UiElement =
  result = newUiElement(UiElementKind.kButton, label=label, events = @[UiEventKind.click])
