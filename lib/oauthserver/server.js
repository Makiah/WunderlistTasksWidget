// Required modules for server.  
var app = require('express')();
var cookieParser = require('cookie-parser');
app.use(cookieParser());
var request = require("request");
var http = require('http');
var server = http.Server(app);
var port = process.env.PORT || 4000;

// Eventually set.  
var access_token = '';
function setAccessToken(new_access_token)
{
    this.access_token = new_access_token;
}
app.get('/pls-can-i-has-access-token', function(req, res)
{
    console.log("Got request, it's " + this.access_token);

    if (this.access_token !== undefined && this.access_token !== '')
    {
        res.send(this.access_token);
        process.exit(0);
    }
    else 
        res.send("nope!");
});

//Variables which are referenced during authentication.
var authenticationParams = {
    authentication_url: "https://www.wunderlist.com/oauth/",
    client_id: "3badb48a0395375f93e0", 
    client_secret: "9f9357a65695cebf5a33e9585afcb6b83f9be1f1c9c97cb1eb5aa9ed2737"
};

app.get('/', function(req, res)
{
    // Do nothing
    res.send("Invalid route");
});

//When a GET request is sent to the app with the code, this is the callback.
app.get('/authorization_code_callback', (req, res) =>
{
    res.send("<p>Thanks!</p><script>setTimeout(function(){self.close();},2000);</script>");

    console.log("Received callback with code " + req.query.code);

    if (req.query.code !== undefined)
    {
        request(
            {
                url: authenticationParams.authentication_url + "access_token",
                method: 'POST',
                json: true,
                body: {
                    "client_id": authenticationParams.client_id, 
                    "client_secret": authenticationParams.client_secret, 
                    "code": req.query.code
                }
            },
            //Only POST methods have a callback.
            (error, response, body) =>
            {
                if (error)
                {
                    console.log("Error: ", error);
                }
                else
                {
                    if (body === undefined)
                    {
                        console.log("Body was undefined...?")
                        return;
                    }

                    if (body.access_token === undefined)
                        console.log("Access-token is not defined!");
                    else
                    {
                        console.log();
                        console.log("Body: ", body);
                        console.log();
                        console.log("Token: ", body.access_token);

                        setAccessToken(body.access_token);
                    }
                }
            }
        );
    }
    else
    {
        console.log("Callback URL code parameter was undefined!");
    }
});

//Create the server.
server.listen(port, function()
{
    console.log('Listening on localhost:' + port);
    console.log(''); //Empty space beautifies debugging IMO
});
