
include karax / prelude 
import karax / [prelude, vstyles]

import sugar, json


proc Card*(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="col")):
    tdiv(class="card mb-4 box-shadow products-card"):
      h5(class="card-header"):
        text def["title"].getStr()
      tdiv(class="card-body d-flex flex-column"):
        p(class="card-text"):
          for pt in def["content"]:
            text pt.getStr()
            if def.hasKey("link"):
              let link = def["link"]
              a(href=link["href"].getStr,
                class="mb-auto card-link btn btn-lg btn-block btn-primary"):
                text link["text"].getStr
          
proc Cards*(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="container")):
    h2(class="section-heading text-center"): text(def["title"].getStr())
    tdiv(class="row justify-content-center align-items-start"):
      for child in def["children"]:
        if child.hasKey("card"):
          Card(child["card"])
