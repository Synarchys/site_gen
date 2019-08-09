
import ../uielement


proc Body*(): UiElement =
  result = newUiElement(UiElementKind.kBody)
