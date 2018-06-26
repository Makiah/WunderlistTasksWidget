# Wunderlist Tasks Widget

<p align="center"> 
<img src="/doc/Screenshot.png">
</p>

I find it very helpful to see upcoming tasks and events right on my desktop, visible with a trackpad swipe, or by minimizing the current window.  Unfortunately, Wunderlist doesn't currently have this functionality, until you use this!

## Installation Procedure
There are a couple things you'll need first.   
* macOS 10.11 - 10.13
* [Übersicht](http://tracesof.net/uebersicht/) — a widget manager for macOS, which is used to render the tasks. 
* [NodeJS](https://nodejs.org) — parses task JSON and completes the Wunderlist OAuth procedure.  I suggest you install via [Brew](https://brew.sh), a package manager for macOS.  This app uses 8.9.0, but any node version should work (just change run.sh).  

Once they're installed, download the [latest release](https://github.com/Makiah/WunderlistTasksWidget/releases) and extract it to the Übersicht widgets folder.  Then open Übersicht, and you should get a screen that looks like this: 

![Request Auth](/doc/Login.png?raw=true "Login")

If you log in, this app should complete the OAuth flow and close the tab, then display your tasks.  If you experience a bug, please report it to the Issues page.  

Note that if you want to ```git clone``` this code, you'll have to also install NPM and run ```npm install``` in /lib/oauthserver and /lib/datadisplay to get the node_modules directories.  

## Configurable Features
Use the `customization.json` file if you need to change settings from the default.  
```
{
    "positioning": {
        "left-offset-percentage": 59,  // the extent to which your widget will be spaced away from the left side of the screen 
        "top-offset-percentage": 5,    // the extent to which your widget will be spaced away from the top side of the screen 
        "width-percentage": 32.5,      // the width of your image, expressed in a percentage of your screen width
        "height-percentage": 90        // the width of your image, expressed in a percentage of your screen height
    }, 
    "lists-to-display": [
    ], 
    "urgency-filters": {
        "display-tasks-without-due-date": true,  // whether to display tasks without a due date
        "display-tasks-due-within-x-days": 7     // the maximum number of days between now and the task's due date for it to be considered "urgent"
    }
}
```

**Disclaimer**: I haven't done a lot to make this code super secure: the Wunderlist access token is obtained by querying the local server, and I also store the token in plain text currently.  If you use Wunderlist for secure work stuff then don't use this unless you're certain there's no risk of being hijacked (I'm a student, the worse thing that could happen is someone delete my test reminder, which would take approximately 5 seconds to put back).  
