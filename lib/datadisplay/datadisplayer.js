/*
This script handles all the querying involved in getting data from the Wunderlist server: it 
prints it all out to the command line so that the widget knows what to do with it.    
*/

// Super convenient :)
var WunderlistSDK = require('wunderlist'); 
var customizationJSON = require('../../customization.json');

var URGENT_TASK_THRESHOLD = customizationJSON["urgency-filters"]["display-tasks-due-within-x-days"];
var includeLists = customizationJSON["lists-to-display"];
var displayTasksWithoutDueDate = customizationJSON["urgency-filters"]["display-tasks-without-due-date"];

// Stuff figured out prior.  
var CLIENT_ID = process.argv[2];
var ACCESS_TOKEN = process.argv[3];

var WunderlistSDK = new WunderlistSDK({
  'accessToken': ACCESS_TOKEN,
  'clientID': CLIENT_ID
});

WunderlistSDK.initialized.then(getLists);

// Gets all lists, and prints their priority tasks.  
function getLists()
{
	// Gets all lists.  
	WunderlistSDK.http.lists.all()
	  .done(printLists)
	  .fail(function () {
	    console.log('An error occurred, couldn\'t get lists :/');
	  });
}

// Determines whether this task is due in the next couple days.  
function daysBetween(date1String, date2String){
  var d1 = new Date(date1String);
  var d2 = new Date(date2String);
  return (d2-d1)/(1000*3600*24);
}

// Prints the priority task from an explicit list.  
function printLists(lists)
{
	var listsComplete = 0;
	var requiredLists = 0;

	lists.forEach((list) =>
	{
		// Decide whether this list name exists in the array
		var containsListName = false;
		if (includeLists.length == 0)
		{
			containsListName = true;
			requiredLists++;
		}
		else 
		{
			for (var i = 0; i < includeLists.length; i++)
			{
				if (list.title === undefined)
					continue;

				if (list.title === includeLists[i])
				{
					containsListName = true;
					requiredLists++;
					break;
				}
			}
		}

		// If we can include this list
		if (containsListName)
		{
			WunderlistSDK.http.tasks.forList(list.id)
				.done((tasks) => 
				{
					var importantTasks = [];

					tasks.forEach(function(task) {
						console.log("Task " + task.title + " is due " + task.due_date);
						if (task.due_date === undefined)
						{
							if (!displayTasksWithoutDueDate)
							{
								console.log("Task is not urgent.");
							}
							else
							{
								console.log("Task is urgent!");
								importantTasks.push(task.title);
							}
							return;
						}

						if (daysBetween(new Date().toISOString(), task.due_date) <= URGENT_TASK_THRESHOLD)
						{
							console.log("Task is urgent!");
							importantTasks.push(task.title + " (due " + task.due_date + ")");
						} else 
						{
							console.log("Task is not urgent.");
						}
					});

					// Tell the widget to add these tasks.  
					if (importantTasks.length > 0)
					{
						console.log("ADDTASKS", JSON.stringify({
							listTitle: list.title, 
							taskNames: importantTasks
						}));
					}

					listsComplete++;

					if (listsComplete == requiredLists)
					{
						process.exit(0);
					}
				});
			}
	});
}

