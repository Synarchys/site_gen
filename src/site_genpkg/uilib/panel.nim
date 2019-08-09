
import ../uielement


proc Panel*(): UiElement =
  result = newUiElement(UiElementKind.kPanel)
