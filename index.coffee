###
So after a crap ton of confusion I think I'm starting to understand this: all this script is supposed to do is offload the processing somewhere else, and then display the resulting output of the offloaded script.  
###

# Properties which are filled in later.  
command: """
sh ./WunderlistTasksWidget/run.sh
"""

# The rate at which the app updates.  
refreshFrequency: 100000

# Called to display this item on the desktop.  
render: (output) -> 
  console.log "Got render" 
  return """  
  <h1>Important Wunderlist Tasks</h1>
  <div id="taskSections">
  </div>
"""

# Takes care of actually inserting the data into the domEl.  
parseTasksJSON: (tasksJSON, domEl) -> 
  tasksString = ""
  for taskName in tasksJSON.taskNames
    tasksString = tasksString + "<li>" + taskName + "</li>"

  $(domEl).find("#taskSections").append("<div class='taskSection'><h2>" + tasksJSON.listTitle + "</h2><ul>" + tasksString + "</ul></div>")


# Called when the refreshFrequency timer expires.  
update: (output, domEl) ->
  console.log "Got update!"
  console.log "Output is ", output

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
  

style: """      
  top: 20px
  left: 20px 
  width: 500px
  height: 600px
  background-color: white
                
  h1            
    color: black 
    width: 100%
    height: 100px;

  #taskSections
    background-color: red;
    width: 100%;
    height: 1500px;

  .taskSection
    background-color: green
    width: 100%;
    height: 500px;
"""