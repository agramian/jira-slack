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

end
