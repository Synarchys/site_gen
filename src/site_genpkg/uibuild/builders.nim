
import tables
import karax / [vdom, kdom, karaxdsl]
import ../uielement

import webbuilder
export webbuilder

# import modular builders
import input, button, form, nav, input, link, menu, checkbox, dropdown, tile, panel


var buildersTable = initTable[UiElementKind, proc(wb: WebBuilder, el: UiElement): Vnode]()
buildersTable.add UiElementKind.kInputText, buildInputText
buildersTable.add UiElementKind.kForm, buildForm
buildersTable.add UiElementKind.kLink, buildLink
buildersTable.add UiElementKind.kButton, buildButton
buildersTable.add UiElementKind.kNavBar, buildNav
buildersTable.add UiElementKind.kMenu, buildMenu
buildersTable.add UiElementKind.kCheckBox, buildCheckBox
buildersTable.add UiElementKind.kDropdown, buildDropdown
buildersTable.add UiElementKind.kPanel, buildPanel
buildersTable.add UiElementKind.kTile, buildTile


proc callBuilder*(wb: WebBuilder, elem: UiElement): VNode =
  var el = elem  
  if buildersTable.haskey el.kind:
    result = buildersTable[el.kind](wb, elem)
    for elkid in el.children:
      let kid = callBuilder(wb, elkid)
      if not kid.isNil:
        result.add kid
  else:
    echo "Builder not found for: " & $el.kind
      

proc initBuilder*(handler: proc(uiev: uielement.UiEvent, el: UiElement, viewid: string): proc(ev: Event, n: VNode)): WebBuilder =
  result = newWebBuilder(handler)
  result.builder = callBuilder
