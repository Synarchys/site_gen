
import ../uielement


proc Form*(): UiElement =
  result = newUiElement(UiElementKind.kForm)
