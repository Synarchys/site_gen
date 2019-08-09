
# Event Listeners
# A list of procs  that handle when a event is triggered

import asyncjs, json, jsffi, tables, sequtils, strutils, times
import site_genpkg / [ui_utils, listeners, store]
import jsonflow, uuidjs

# Imports appState as global Object
import datastore


# event handlers  
EventHandlers:
  # do not add procs that are not event handlers
  proc sitegen_default_action(payload: JsonNode) =
    echo "sitegen_default_action"
    updateLoginObj(payload)
  
  proc default_action_input_keyup(payload: JsonNode) =
    echo "default_action_input_keyup"
    echo "olidjeowiejdoiwejdoiwoi"
    echo "olidjeowiejdoiwejdoiwoi"
    echo "olidjeowiejdoiwejdoiwoi"
    updateLoginObj(payload)
    
    
  proc default_action_button_click(payload: JsonNode) =
    echo "default_action_button_click"
    echo payload.pretty
