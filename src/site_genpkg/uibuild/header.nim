
include karax / prelude
import karax / [kbase, kdom, vdom, karaxdsl]

import ../uielement, ../ui_utils
import webbuilder


proc buildHeader*(b: WebBuilder, header: UiElement, viewid: string): VNode =
  result = buildHtml(header(class="navbar")):
    for men in header.children:
      if men.kind == UiElementKind.kNavBar:
        for sect in men.children:
          if sect.kind == UiElementKind.kNavSection:
            section(class="navbar-section"):
              for l in sect.children:
                if l.kind == UiElementKind.kLink:
                  build(b, l, viewid)
