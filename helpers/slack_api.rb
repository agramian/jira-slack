require_relative 'request_helper'

class SlackApi
        
  def initialize
    @@request_helper = RequestHelper.new
    @@token_param = {
      'token'=> ENV['SLACK_AUTH_TOKEN']
    }   
  end

  def check_response_ok(endpoint, response)
    if !JSON.parse(response.body)['ok']
        raise RequestError.new(endpoint, response)
    end
  end    

  def get_users()
    endpoint = ENV['SLACK_BASE_URL'] + 'users.list'
    response = @@request_helper.request('GET', endpoint, return_raw=true, :query => @@token_param)
    check_response_ok(endpoint, response)
    return JSON.parse response.body
  end
  
  def post_message(channel,
                   message=nil,
                   username='GitHub-Redmin Bot',
                   attachments=nil,
                   color=nil,
                   as_user=nil,
                   icon_emoji=nil,
                   icon_url=nil)
    endpoint = ENV['SLACK_BASE_URL'] + 'chat.postMessage'
    post_data = {
      'as_user' => as_user,
      'username' => username,
      'text' => message,
      'attachments' => attachments.to_json,
      'channel' => channel,
      'icon_emoji' => icon_emoji,
      'icon_url' => icon_url,
      'link_names' => 1
    }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('POST', endpoint, return_raw=true, :query => @@token_param, :body => post_data)
    check_response_ok(endpoint,response)
    return JSON.parse response.body
  end

end
