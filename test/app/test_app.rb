require_relative '../test_helper'

class AppTest < WebhookTest

  def test_send_slack_message
    # will raise exception if request was unsuccessful
    slack_api = SlackApi.new
    slack_api.post_message(
      channel: "@#{ENV['SLACK_DEFAULT_RECIPIENT']}",
      message: 'test',
      username: 'JIRA',
      icon_emoji: ':smile_cat:')
  end

  def test_post_jira
    response = post '/jira_hook', @jira_data['updated']
    assert_equal 200, response.status
  end

end
