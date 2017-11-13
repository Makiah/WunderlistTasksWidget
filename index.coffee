###
So after a crap ton of confusion I think I'm starting to understand this: all this script is supposed to do is offload the processing somewhere else, and then display the resulting output of the offloaded script.  
###

# Properties which are filled in later.  
command: """
sh ./WunderlistTasksWidget/run.sh
"""

# The rate at which the app updates.  
refreshFrequency: 10000

# Takes care of actually inserting the data into the domEl.  
parseTasksJSON: (tasksJSON, domEl) -> 
  tasksString = ""
  for taskName in tasksJSON.taskNames
    tasksString = tasksString + "<li>" + taskName + "</li>"

  if (tasksString != "")
  	$(domEl).find("#container").append("<div class='listHeading'><h3>" + tasksJSON.listTitle + "</h3></div><div class='listContents'><ul>" + tasksString + "</ul></div>")


# Called when the refreshFrequency timer expires.  
update: (output, domEl) ->
  console.log "Got update!"
  console.log "Output is ", output

  # Empty the current list of tasks (will just be repopulated otherwise)
  $(domEl).find('#container').empty()

  # Split output into single line snippets
  outputs = output.split("\n")
  console.log("Snipped to", outputs);

  # Find the ADDTASKS lines and parse them.  
  for line in outputs 
    if line.indexOf("ADDTASKS") != -1
      # Adds a new set of tasks to the visible list.  
      tasksJSON = JSON.parse(line.substring(8, line.length))
      console.log("Tasks JSON is", tasksJSON)
      @parseTasksJSON(tasksJSON, domEl)
  

# Called to display this item on the desktop.  
render: (output) -> 
  console.log "Got render" 
  return """  
  <div id="container">
  </div>
"""

style: """      
  top: 5px
  left: 5px 
  width: 400px
  height: 765px

  #container
  	background-color: rgba(80, 80, 80, 0.51)
  	border: 1px solid white
  	width: 400px;
  	height: 765px;

  .listHeading
  	width: calc(100% - 20px)
  	background-color: rgba(74, 74, 74, 0.65)
  	padding: 10px

  .listHeading h3 
  	font-family: sans-serif
  	color: white

  .listContents ul
  	list-style: none
  	padding: 0
  	margin: 0

  .listContents li
  	color: white
  	font-family: sans-serif
  	margin: 8px 10px;

  h1,h2,h3
  	margin: 0
"""