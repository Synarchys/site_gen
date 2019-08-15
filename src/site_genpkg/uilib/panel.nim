
import ../uielement
import ../uibuild/panel

proc Panel*(): UiElement =
  result = newUiElement(UiElementKind.kPanel)
  result.builder = buildPanel
