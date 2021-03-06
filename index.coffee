###
So after a crap ton of confusion I think I'm starting to understand this: all this script is supposed to do is offload the processing somewhere else, and then display the resulting output of the offloaded script.  
###

# Properties which are filled in later.  
command: """
sh ./WunderlistTasksWidget/run.sh
"""

# The rate at which the app updates.  
refreshFrequency: 60000

# Takes care of actually inserting the data into the domEl.  
parseTasksJSON: (tasksJSON, domEl) -> 
  tasksString = ""
  for taskName in tasksJSON.taskNames
    tasksString = tasksString + "<li>" + taskName + "</li>"
    
  if (tasksString != "")
  	$(domEl).find("#taskListsContainer").append("<div class='listHeading'><h3>" + tasksJSON.listTitle + "</h3></div><div class='listContents'><ul>" + tasksString + "</ul></div>")


# Inspiration from https://github.com/atika/Ubersicht-GitFinder/blob/53b6b8eda1959902741a9be7db6f247af82e4a8c/GitFinder.widget/index.coffee
setPosition: (position, domEl) ->
  # Position is a string of left % | top % | width % | height %	
  # POSITION OF THE WIDGET
  positions = position.split("|")
  $(domEl).css({'left': positions[0] + "%",'top': positions[1] + "%",'width': positions[2] + "%",'height': positions[3] + "%"})


# Called when the refreshFrequency timer expires.  
update: (output, domEl) ->
  console.log("Update refreshed");

  # Split output into single line snippets
  outputs = output.split("\n")
  console.log("Update lines are", outputs);

  # Parse the customization file.  
  config = JSON.parse(outputs[outputs.indexOf("CONFFILE") + 1])
  console.log("Config file is " + JSON.stringify(config))
  positioningString = config["positioning"]["left-offset-percentage"] + "|" + config["positioning"]["top-offset-percentage"] + "|" + config["positioning"]["width-percentage"] + "|" + config["positioning"]["height-percentage"]
  console.log("Positioning will be " + positioningString)
  @setPosition(positioningString, domEl)

  # Quit this early if we're online.  
  if outputs.indexOf("OFFLINE") != -1
    console.log("Currently offline, not updating.")
    return;

  # Empty the current list of tasks (will just be repopulated otherwise)
  $(domEl).find('#taskListsContainer').empty()
  $(domEl).find('#errorContainer').empty()

  # Find the ADDTASKS lines and parse them.  
  for line in outputs 
    if line.indexOf("ERROR: ") != -1
      # Adds the error to the visible window.  
      $(domEl).find('#errorContainer').append("<p>" + line.substring(7, line.length) + "</p>")

    if line.indexOf("ADDTASKS") != -1
      # Adds a new set of tasks to the visible list.  
      tasksJSON = JSON.parse(line.substring(8, line.length))
      console.log("Tasks JSON is", tasksJSON)
      @parseTasksJSON(tasksJSON, domEl)
  

# Called to display this item on the desktop.  
render: (output) -> 
  console.log "Got render" 
  return """  
  <div id="wunderlistHeading">
    <div id="subWunderlistHeading"></div>
    <img src="./WunderlistTasksWidget/wunderlist-icon.png"/>
  </div>
  <div id="errorContainer">
  </div>
  <div id="taskListsContainer">
  </div>
"""

style: """      
  top: 0px
  left: 48% 
  width: 30%
  height: 765px

  #wunderlistHeading
    text-align: center;

  #subWunderlistHeading
    background-color: rgba(255, 255, 255, 0.8);
    margin-bottom: 5px
    height: 70px;
    width: 100%
    top: 15px;
    z-index: -1;
    position: absolute;
    border-radius: 5px

  #wunderlistHeading img 
    height: 100px;
    width: 100px;

  #errorContainer
    background-color: rgba(74, 74, 74, 0.7)

  #errorContainer p
    color: red
    font-family: sans-serif
    font-size: 20px;

  .listHeading
    width: calc(100% - 20px)
    background-color: rgba(74, 74, 74, 0.7)
    padding: 10px
    border-top-left-radius: 5px;
    border-top-right-radius: 5px;

  .listHeading h3 
  	font-family: sans-serif
  	color: white
    
  .listContents
    background-color: rgba(74, 74, 74, 0.4);
    border-left: 1px solid rgba(74, 74, 74, 0.7);
    border-bottom: 1px solid rgba(74, 74, 74, 0.7);
    border-right: 1px solid rgba(74, 74, 74, 0.7);
    padding: 10px;
    margin-bottom: 5px;
    border-bottom-left-radius: 5px;
    border-bottom-right-radius: 5px;

  .listContents ul
  	list-style: none
  	padding: 0
  	margin: 0

  .listContents li
  	color: white
  	font-family: sans-serif
  	margin: 0px 0px 10px 0px

  h1,h2,h3
  	margin: 0
"""