
# This module defines the type for the base ui component.
# The ui component is used to isolate ui elements and its events when needed for complex components

import json, tables, unicode

type
  BaseComponent* = object of RootObj
    renderImpl*: proc(lib, def: JsonNode, data: JsonNode = nil): JsonNode
    actions*: Table[cstring, proc(payload: JsonNode){.closure.}]


template newBaseComponent*[T](t: typeDesc[T],
                              render: (proc(lib, def: JsonNode, data: JsonNode = nil): JsonNode)): T =
  T(renderImpl: render)
                              
template newBaseComponent*[T](t: typeDesc[T],
                              render: (proc(lib, def: JsonNode, data: JsonNode = nil): JsonNode),
                              a: Table[cstring, proc(payload: JsonNode){.closure.}]): T =
  T(renderImpl: render, actions: a)

