
include karax / prelude 
import karax / [prelude, vstyles]

import cards

proc Paragraph(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="col-md text-justify")):
    h2(class="section-heading text-center"): text(def["title"].getStr())
    for child in def["children"]:
      if child.hasKey("p"):
        for pa in child["p"]:
          p: text pa.getStr()


proc Contact(def: JsonNode): VNode =
  result = buildHtml(tdiv(class="container")):
    tdiv(class="row"):
      tdiv(class="col text-center"):
        h2(class="section-heading text-center"):
          text def["title"].getStr()
    h3(class="section-subheading text-muted")
    tdiv(class="text-justify text-black"):
      tdiv(class="container"):
        tdiv(class="row"):
          for c in def["children"]:
            tdiv(class="col text-justify"):
              h2: text c["title"].getStr()
              for l in c["p"]:
                p: text l.getStr()

          
proc Sections*(def: JsonNode): VNode =
  let sections  = def["sections"]
  result = buildHtml(tdiv()):
    for sect in sections:
      section(class="bg-white", id=sect["id"].getStr()):
        if sect["type"].getStr == "text":
          tdiv(class="container"):
            Paragraph(sect)
        elif sect["type"].getStr == "cards":
          Cards(sect)
        elif sect["type"].getStr == "rows":
          Contact(sect)
   
