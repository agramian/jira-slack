ENV['RACK_ENV'] = 'test'
require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
require 'json'

class WebhookTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    # import json data to hash
    @jira_data = {}
    Dir[File.dirname(__FILE__) + '/data/json/jira/*' ].each {|file|
      File.open(file, 'rb') { |f|
        data = JSON.parse(f.read)
        @jira_data[File.basename(file, File.extname(file))] = data.to_json
      }
    }
    super
  end

  def app
    Sinatra::Application
  end
end
