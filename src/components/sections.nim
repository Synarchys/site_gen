
include karax / prelude 
import karax / [prelude, vstyles]

import sugar, json

proc Paragraph(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="col-md text-justify")):
    h2(class="section-heading text-center"): text(def["title"].getStr())
    for child in def["children"]:
      if child.hasKey("p"):
        for pa in child["p"]:
          p: text pa.getStr()

proc Card(def: JsonNode): VNode =
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
          
proc Cards(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="container")):
    h2(class="section-heading text-center"): text(def["title"].getStr())
    tdiv(class="row justify-content-center align-items-start"):
      for child in def["children"]:
        if child.hasKey("card"):
          Card(child["card"])


# proc contact(contacts: JsonNode): VNode =
#   result = buildHtml(section(class="bg-white", id="contact")):
#     tdiv(class="container"):
#       tdiv(class="row"):
#         tdiv(class="col text-center"):
#           h2(class="section-heading text-center"): text "Contact"
#       h3(class="section-subheading text-muted")
#       tdiv(class="text-justify text-black"):
#         tdiv(class="container"):
#           tdiv(class="row"):
#             for c in contacts["items"]:
#               tdiv(class="col text-justify"):
#                 h2: text c["name"].getStr()
#                 for l in c["address_lines"]:
#                   p: text l.getStr()
#                 p:
#                   a(href=c["email"].getStr()): text c["email"].getStr()
          
proc Sections*(def: JsonNode): VNode =
  let sections  = def["container"]["sections"]
  result = buildHtml(tdiv()):
    for sect in sections:
      section(class="bg-white", id=sect["id"].getStr()):
        if sect["type"].getStr == "text":
          tdiv(class="container"):
            Paragraph(sect)
        elif sect["type"].getStr == "cards":
          Cards(sect)
        elif sect["type"].getStr == "rows":
          # tdiv(class="container"):
          #   h2(class="section-heading text-center"): text(sect["title"].getStr())
          #   tdiv(class="row justify-content-center align-items-start")
          tdiv(class="container"):
            tdiv(class="row"):
              tdiv(class="col text-center"):
                h2(class="section-heading text-center"):
                  text sect["title"].getStr()
            #Paragraph(sect)
            
