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
    change_fields = []
    case event_type
    when 'jira:issue_updated'
      event_type = 'Issue Updated'
      # add a hash for each change log event
      # to include in the slack messaage
      data['changelog']['items'].each do |item|
        change_fields << {
          'title': "Field #{item['field']} changed",
          'value': "#{item['fromString']} -> #{item['toString']}"
        }
      end
      # add hash for the comment (if any)
      # to include in the slack message
      if data['comment']
        change_fields << {
          'title': "Comment added/updated",
          'value': "*@#{data['comment']['updateAuthor']['name']} wrote*:\n#{data['comment']['body']}"
        }
      end
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
          recipient_list << data['issue']['fields'][field]['name']
        end
    end
    # get watchers
    watchers = []
    jira_api.get_issue_watchers(data['issue']['id'])['watchers'].each do |watcher|
      recipient_list << watcher['name']
    end
    # user mention regex
    user_mention_regex = Regexp.new(/\[\~([^]]+)\]/)
    # get user mentions in issue description
    issue = jira_api.get_issue(data['issue']['id'])
    if issue['fields']['description']
      issue['fields']['description'].scan(user_mention_regex).flatten.each do |name|
        recipient_list << name
      end
    end
    # get user mentions in comments
    jira_api.get_issue_comments(data['issue']['id'])['comments'].each do |comment|
      recipient_list << comment['author']['name']
      recipient_list << comment['updateAuthor']['name']
      comment['body'].scan(user_mention_regex).flatten.each do |name|
        recipient_list << name
      end
    end
    # convert recipient_list to set to remove duplicates
    recipient_list = recipient_list.to_set
    # remove the user that triggered the event
    recipient_list.delete(event_user)
    # notify each recipient via slack
    issue_link = '<https://jira.guidebook.com/browse/%s|%s %s>' %[data['issue']['key'], data['issue']['key'], data['issue']['fields']['summary']]
    recipient_list.each do |user|
      slack_api.post_message(
        channel: "@#{user}",
        attachments: [{
          'title': event_type,
          'text': issue_link,
          'fallback': issue_link,
          'mrkdwn_in': ['text', 'pretext', 'fields', 'title'],
          'fields': change_fields
        }],
        username: 'JIRA',
        icon_emoji: "#{ENV['SLACK_EMOJI']}")
    end
  	'OK'
  rescue => exception
    status 500
    exception = "Exception occured while processing jira_hook!" \
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
