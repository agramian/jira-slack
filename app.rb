require 'dotenv'
Dotenv.load
require 'sinatra'
require 'httparty'
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file}
require 'set'

# initialize classes
jira_api = JiraApi.new
slack_api = SlackApi.new

post '/jira_hook' do
  begin
  	data = JSON.parse(request.body.read)
    # get event type
    event_type = data['webhookEvent']
    case event_type
    when 'jira:issue_updated'
      event_type = 'Issue Updated'
    when 'jira:issue_created'
      event_type = 'Issue Created'
    end
    # gather list of slack recipients to notify
    recipient_list = []
    # get user that triggered the event to exclude them
    event_user = data['user']['name']
    # get issue reporter, creator, and assignee if any
    ['reporter', 'creator', 'assignee'].each do |field|
        if data['issue'][field]
          recipient_list << data['issue'][field]['name']
        end
    end
    # get watchers
    watchers = []
    jira_api.get_issue_watchers(data['issue']['id'])['watchers'].each do |watcher|
      recipient_list << watcher['name']
    end
    # TODO get user mentions in issue body
    # TODO get comment authors and user mentions in comment body
    # convert recipient_list to set to remove duplicates
    recipient_list.to_set
    # remove the user that triggered the event
    recipient_list.delete(event_user)
    # notify each recipient via slack
    slack_api.post_message(
      channel: "@#{ENV['SLACK_DEFAULT_RECIPIENT']}",
      attachments: [{
        'title': event_type,
        'text': '<https://jira.guidebook.com/browse/%s|%s>' %[data['issue']['key'], data['issue']['key']],
      }],
      username: 'JIRA',
      icon_emoji: ':smile_cat:')
  	'OK'
  rescue => exception
    status 500
    exception = "Exception occured while processing redmine_hook!" \
                "\nBacktrace:\n\t#{exception.backtrace.join("\n\t")}" \
                "\nMessage: #{exception.message}"
    puts exception
    slack_api.post_message(
      channel: "@#{ENV['SLACK_DEFAULT_RECIPIENT']}",
      message: exception.to_s,
      username: 'JIRA',
      icon_emoji: ':crying_cat_face:')
    exception
  end
end
