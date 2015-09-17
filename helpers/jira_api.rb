require_relative 'request_helper'

class JiraApi

  def initialize
    @@request_helper = RequestHelper.new
    @@headers = {
      'Content-Type' => 'application/json'
    }
    @@basic_auth = {
      :username => ENV['JIRA_USERNAME'],
      :password => ENV['JIRA_PASSWORD']
    }
  end

  def get_issue(id)
    return @@request_helper.request(
      'GET',
      ENV['JIRA_BASE_URL'] + 'issue/%s' %[id.to_s],
      :basic_auth => @@basic_auth,
      :headers => @@headers)
  end

  def get_issue_watchers(id)
    return @@request_helper.request(
      'GET',
      ENV['JIRA_BASE_URL'] + 'issue/%s/watchers' %[id.to_s],
      :basic_auth => @@basic_auth,
      :headers => @@headers)
  end

end
