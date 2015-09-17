require 'dotenv'
Dotenv.load
require 'sinatra'
require 'httparty'
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file}

# initialize classes
slack_api = SlackApi.new

post '/jira_hook' do
  begin
  	data = JSON.parse(request.body.read)
    slack_api.post_message(
      channel: "@#{ENV['SLACK_DEFAULT_RECIPIENT']}",
      message: data.to_s,
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
