

include karax / prelude
import karax / [kdom, vdom]

import ../uielement, ../ui_utils
import webbuilder


#proc buildDropdownItem*(wb: WebBuilder, el: UiElement): Vnode =
#  result = buildHtml():
   
proc buildDropdown*(wb: WebBuilder, el: UiElement): VNode =
  result = buildHtml():
    tdiv(class="form-group"):
      select(class="form-select"):
        for child in el.children:
          if child.kind == kDropdownItem:
            option(value = child.value):
              text child.label

