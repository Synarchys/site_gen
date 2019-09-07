
import os, osproc, strutils, tables

const site_gen = "site_gen"

# options
const csslib = ("--csslib", ["bootstrap", "bulma"])


proc extractOptions(params: seq[string]): OrderedTable[string, seq[string]] =  
  if params.len > 2:
    var lastKey = ""
    for p in params[2 .. len(params)-1]:
      if p.startsWith("--"):
        lastKey = p
        result.add(p, @[])
      else:
        # get last key
        result[lastKey].add p


# proc copyInitFiles(options: OrderedTable[string, seq[string]], targetDir: string,
#                    kind: PathComponent, path: string) =
#   let
#     splitPath = path.split("/")
#     copiedDir = splitPath[len(splitPath) - 1]
#     target = targetDir & "/" & copiedDir
#   if kind == PathComponent.pcDir:
#     # if it is a dir, 
#     echo "pcDir"
#     echo path
#     for k, p in os.walkDir(path):    
#       copyInitFiles(options, targetDir, k, p)
#     #os.copyDirWithPermissions(path, target)
#   elif kind == PathComponent.pcFile:
#     echo "pcFile"
#     echo path
#     #os.copyFileWithPermissions(path, target)
  
        
proc init(params: seq[string]) =
  var
    targetDir = ""
    binPath = os.findExe(site_gen)
    baseAppDir = ""
    options = extractOptions(params)
                  
  binPath.removeSuffix(site_gen)  
  
  if params.len > 1:
    targetDir = params[1]
    if targetDir.startsWith("--"):
      echo "Please provide the name of the project:"
      echo "#]site_gen init myproj"
      quit(-1)
    else:
      echo "Creating " & targetDir & " ..."
      createDir(targetDir)
  
  if os.existsDir(binPath / "baseapp"):
    baseAppDir = binPath / "baseapp"
  elif os.existsDir(binPath / "src/baseapp/"):
    baseAppDir = binPath / "src/baseapp/"
  
  if baseAppDir != "":
    echo "coping from: $1 to $2" % [baseAppDir, targetDir]
    for kind, path in os.walkDir(baseAppDir):
      if kind == PathComponent.pcDir:
        if path.endsWith("/public") and options.haskey(csslib[0]) and options[csslib[0]].len > 0:
          let val = options[csslib[0]][0]
          if val in csslib[1]:
            echo "Copying " & path / val & " to " & targetDir / "public"
            os.copyDirWithPermissions(path / val,  targetDir / "public")
        else:          
          echo "Please select your prefered css library:"
          echo "site_gen " & targetDir & " --csslib " & $csslib[1]

      elif kind == PathComponent.pcFile:
        let fileName = path.substr(path.rfind("/") + 1)
        echo "Copying " & path & " to " & targetDir & "/" & fileName
        os.copyFileWithPermissions(path, targetDir & "/" & fileName)
      

proc build() =
  const buildCmd = "nim js -o:public/js/index.js index.nim"
  let
    projectRoot = os.getCurrentDir()
    output = execProcess(buildCmd)
    
  for kind, path in os.walkDir(projectRoot):
    echo path

    
when declared(commandLineParams):
  let
    params = commandLineParams()
    initIndx = params.find("init")
    buildIndx = params.find("build")
    
  if initIndx > -1:
    init(params)
  elif buildIndx > -1:
    build()
  else:    
    echo "Invalid parameters."
    echo " init <path>:     path the target dir where the website will be initialized"
    echo " build:           builds the site."
