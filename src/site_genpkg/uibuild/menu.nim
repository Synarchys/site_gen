
import karax / [vdom, karaxdsl]
import ../uielement, ../ui_utils
import webbuilder

# TODO:
proc buildMenuItem(el: UiElement): Vnode =
  result = buildHtml():
    li(class="menu-item"):
      a:
        text el.value
  
  
proc buildMenu*(wb: WebBuilder, menu: UiElement): VNode =
  result = buildHtml():
    ul(class="menu"):
      li(class="divider", data-content=menu.value)
      for menuItem in menu.children:
        if menuItem.kind == kMenuItem:
          buildMenuItem(menuItem)
