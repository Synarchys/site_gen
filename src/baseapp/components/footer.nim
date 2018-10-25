include karax / prelude 
import karax / [prelude, kdom]

import json

proc Footer*(def: JsonNode):Vnode =
  result = buildHtml():
    footer( class="bg-dark"):
       tdiv(class="container"):
         tdiv(class="row"):
           tdiv(class="col-md-4"):
             span(class="copyright"):
               text "Copyright © SiteGen 2018"

