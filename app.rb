require 'dotenv'
Dotenv.load
require 'sinatra'
require 'httparty'

post '/jira_hook' do
  begin
  	data = JSON.parse(request.body.read)['payload']
  	'OK'
  rescue => exception
    status 500
    exception = "Exception occured while processing redmine_hook!" \
                "\nBacktrace:\n\t#{exception.backtrace.join("\n\t")}" \
                "\nMessage: #{exception.message}"
    puts exception
    exception
  end
end
