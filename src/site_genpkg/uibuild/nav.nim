
import karax / [vdom, karaxdsl]

import ../uielement, ../ui_utils
#import webbuilder


proc buildNav*(b: WebBuilder, header: UiElement): VNode =
  result = buildHtml(header(class="navbar")):
    for men in header.children:
      if men.kind == UiElementKind.kNavBar:
        for sect in men.children:
          if sect.kind == UiElementKind.kNavSection:
            section(class="navbar-section"):
              for l in sect.children:
                if l.kind == UiElementKind.kLink:
                  build(b, l)
