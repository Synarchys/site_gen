
include karax / prelude 
import karax / [prelude, vstyles]

import sugar, json

# TODO: move section header somewhere from the components

proc Paragraph(def: JsonNode): VNode =
  echo $def
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
          tdiv(class="card", style= style(StyleAttr.width, "33rem")):
            img(class="card-img-top", src="...",alt="Card image cap")
            tdiv(class="card-body"):
              h5(class="card-title"): text c["title"].getStr()
              p(class="card-text"):
                for pt in c["content"]:
                  text pt.getStr()
                if c.hasKey("link"):
                  let link = c["link"]
                  tdiv():
                    a(href=link["href"].getStr, class="btn btn-primary"): text link["text"].getStr


proc Sections*(def: JsonNode): VNode =
  let sections  = def["container"]["sections"]
  result = buildHtml(tdiv()):
    for sect in sections:
      section(class="bg-white", id=sect["id"].getStr()):
        tdiv(class="container"):
          if sect["type"].getStr == "text":          
            tdiv(class="row"):
              Paragraph(sect)
          elif sect["type"].getStr == "cards":
            Card(sect)
