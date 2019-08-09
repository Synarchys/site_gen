
import ../uielement


proc Header*(): UiElement =
  result = newUiElement(UiElementKind.kHeader)
