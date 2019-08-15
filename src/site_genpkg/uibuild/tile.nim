
# <div class="tile-icon">
#   <figure class="avatar"><img src="../img/avatar-1.png" alt="Avatar"></figure>
# </div>
# <div class="tile-content">
#   <p class="tile-title text-bold">Thor Odinson</p>
#   <p class="tile-subtitle">Earth's Mightiest Heroes joined forces to take on threats that were too big for any one hero to tackle...</p>
# </div>

import karax / [vdom, karaxdsl]
import ../uielement
# import webbuilder

proc buildTileIcon*(el: UiElement): Vnode =
  result = buildHtml():
    tdiv(class="tile-icon"):
      figure(class="avatar"):
        img(src = el.value, alt = el.label)


proc buildTile*(wb: WebBuilder, el: UiElement): Vnode =
  result = buildHtml():
    for child in el.children:
      # use only one
      if child.kind == UiElementKind.kIcon:
        result.add buildTileIcon child
        break
    
    tdiv(class="tile-content"):
      p(class="tile-title text-bold"): text el.label
      p(class="tile-subtitle"): text el.value
