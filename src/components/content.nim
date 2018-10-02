
include karax / prelude 
import karax / [prelude, vstyles]

import sugar, json

proc Card(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="card", style= style(StyleAttr.width, "18rem"))):
    img(class="card-img-top", src="...",alt="Card image cap")
    tdiv(class="card-body"):
      h5(class="card-title"): text def["title"].getStr()
      p(class="card-text"):
        text def["content"].getStr()
        if def.hasKey("link"):
          let link = def["link"]
          a(href=link["href"].getStr, class="btn btn-primary"): text link["text"].getStr

proc Content*(def: JsonNode): VNode =
  let children  = def["container"]["children"]
  result = buildHtml(section(class="bg-white")):
    tdiv(class="container"):
      tdiv(class="row"):
        for child in children:
          tdiv(class="col-md"):
            if child.hasKey("card"):
              Card(child["card"])
