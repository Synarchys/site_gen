
include karax / prelude 
import karax / [prelude, vstyles]

import sugar, json

# TODO: move section header somewhere from the components

proc Paragraph(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="col-md text-justify")):
    h2(class="section-heading text-justify"): text(def["title"].getStr())
    for child in def["children"]:
      if child.hasKey("p"):
        for pa in child["p"]:
          p: text pa.getStr()

proc Card(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="row")):
    h2(class="section-heading text-justify"): text(def["title"].getStr())
    tdiv(class="row"):
      for child in def["children"]:
        if child.hasKey("card"):
          let c = child["card"]
          tdiv(class="card", style= style(StyleAttr.width, "22rem")):
            img(class="card-img-top", src="...",alt="Card image cap")
            tdiv(class="card-body"):
              h5(class="card-title"): text c["title"].getStr()
              p(class="card-text"):
                text c["content"].getStr()
                if c.hasKey("link"):
                  let link = c["link"]
                  tdiv():
                    a(href=link["href"].getStr, class="btn btn-primary"): text link["text"].getStr


proc Content*(def: JsonNode): VNode =
  let sections  = def["container"]["sections"]
  result = buildHtml(section(class="bg-white")):
    tdiv(class="container"):
      for sect in sections:
        if sect["type"].getStr == "text":
          tdiv(class="row"):
            Paragraph(sect)
        if sect["type"].getStr == "cards":
            Card(sect)
