###
So after a crap ton of confusion I think I'm starting to understand this: all this script is supposed to do is offload the processing somewhere else, and then display the resulting output of the offloaded script.  
###

# Properties which are filled in later.  
command: """
sh WunderlistTasksWidget/run.sh &
"""

# The rate at which the app updates.  
refreshFrequency: 500000

# Called to display this item on the desktop.  
render: (output) -> """  
  <div class="container">
    <h1>Testing</h1>
  </div>
"""

# Called when the refreshFrequency timer expires.  
update: (output, domEl) ->
  console.log "Got update!"
  console.log "Output is ", output
  console.log "DomEl is ", domEl


style: """      
  top: 20px
  left: 20px 
  width: 500px
  height: 500px
  background-color: white;
                
  h1            
    color: black 
          
  div            
    width: 100px 
    height: 100px 
"""