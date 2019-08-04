

include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils


proc buildMenuItem(el: UiElement, viewid: string): Vnode =
  result = buildHtml():
    li(class="menu-item"):
      a:
        text el.value
  
  
proc buildMenu*(menu: UiElement, viewid: string): VNode =
  result = buildHtml():
    ul(class="menu"):
      li(class="divider", data-content=menu.value)
      for menuItem in menu.children:
        buildMenuItem(menuItem, viewid)
