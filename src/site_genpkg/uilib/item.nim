#item component
import json
import ../uielement.nim
import karax / [kdom, vdom, karaxdsl]
import baseui

proc buildItem(): VNode =
  discard

proc Item*(label: string, value: string): UiElement =
  result = newUiElement(UiElementKind.kItem)
  result.label = label
  result.value = value
  
