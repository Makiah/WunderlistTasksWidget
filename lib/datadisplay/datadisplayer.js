/*
This script handles all the querying involved in getting data from the Wunderlist server: it 
prints it all out to the command line so that the widget knows what to do with it.    
*/

// Super convenient :)
var WunderlistSDK = require('wunderlist');
var TasksService = require('services/Tasks');
var tasks = new TasksService();

// Stuff figured out prior.  
var CLIENT_ID = process.argv[2];
var ACCESS_TOKEN = process.argv[3];

var wunderlistAPI = new WunderlistSDK({
  'accessToken': ACCESS_TOKEN,
  'clientID': CLIENT_ID
});

// Gets all lists.  
wunderlistAPI.http.lists.all()
  .done((lists) => {
  	console.log("Lists:", lists);
  	for (var list of lists)
  	{
  		var listData = {
  			listName: list.title,
  			listTasks: []
  		};

  		// Gets all tasks for the list.  
  		tasks.forList(list.id)
	      .done( (tasks, statusCode) => { 
	      	for (var task of tasks) 
	      	{
	      		// Ensure that the task will be due in the next couple of days.   

	      		// Set up task and add it to the list if it satisifies that criteria.  
	      		var taskData = {
	      			"name": task.title, 
	      			"due": task.due_date
	      		}
	      		listData.listTasks.push(taskData)
	      	}

		    // Tell the widget that we want to display this. 
		    console.log("ADD THIS");
		    console.log(listData);
	      })
	      .fail(function (resp, code) {
	        console.log('An error occurred, couldn\'t get tasks for ' + list.title);
	      });
  	}
  })
  .fail(function () {
    console.log('An error occurred, couldn\'t get lists :/');
  });
