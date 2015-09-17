JIRA Slack Integration
==========================

Description
-----------
A web server which receives issue updates from a JIRA webhook and then sends private slack messages to all user's associated with the issue.

Setup
-----
#### JIRA

###### Configure Webhook
Create a webhook through JIRA with the issue created/updated events.

#### Environment variables
Create a `.env` file in the project root to define the necessary environment variables.
Example file below:
```
JIRA_BASE_URL='https://jira.example.com/'
JIRA_USERNAME='user'
JIRA_PASSWORD='password'

SLACK_BASE_URL='https://example.slack.com/api/'
SLACK_AUTH_TOKEN='xxxxx'
```

#### Field mapping
Modify the `db\seeds.rb` file to map Redmine and GitHub fields.

#### Installing dependencies

###### Bundle and bootstrap
```
# for development
bundle
# for production
bundle install --without test development`
```

Running
-------

#### Test and Development
`rerun "rackup"` to start server.
`rake test` to run all tests once.
`ruby ./test/app/TEST_SCRIPT.rb -n TEST_CLASS#TEST_CASE` to run an individual test.
`bundle exec guard` to initiate file watch and run tests on every change.

### Debugging
`racksh` to start console  
Ex:  
`$rack.get '/test-endpoint'`  
`$rack.post "/users", :user => { :name => "Jola", :email => "jola@misi.ak" }`  
`reload!` to restart console after changes  
['More info'](https://github.com/sickill/racksh)

### Production
Run bundle and bootstrap commands from above with `RACK_ENV=production`.
Run `RACK_ENV=production rackup`.

Other
-----
In case API responses change in the future, to generate test JSON data from the webhooks place the following code block in the app.rb `post /jira` method.
Then create/update/close issues etc. from JIRA and save the files appropriately.
```
File.open(File.join(File.dirname(__FILE__), 'test/json_responses/jira_test.json'),"w") do |f|
  f.write(request.body.read)
end
```

### Technology

- Ruby 2.2
- Sinatra
