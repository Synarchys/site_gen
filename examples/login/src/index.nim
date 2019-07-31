
import tables, json, jsffi, asyncjs, times, strutils, unicode

# lib imports
import site_genpkg / [main, appcontext, uielement]

# local imports
import login / [events, datastore]
import login / components / layout

var context = AppContext()
context.state = %*{"store": %*{}}

var app = App()
app.ctxt = context

app.id = "login_example"
app.title = "Login Example"
app.state = "loading"
app.ctxt.actions = actions


proc setTimeout(cb:proc(), timeout: int){.importc: "setTimeout"}
proc delay(ms: int): Future[void] =
  var cb = proc() =
    echo "Initializing"
    app.state = "ready"
    app.layout = layout(app.ctxt)
    reRender()
    
  proc handler(resolve: proc())= 
    setTimeout(cb, ms)
    resolve()
  result = newPromise(handler)


proc init(): Future[void] {.async.} =
  await initStore(app.ctxt, reRender)  
  await delay(500) # test code, wait for initialization
  #reRender()
  
discard init()
createApp(app)

