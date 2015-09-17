require 'json'
require 'httparty'

class RequestError < Exception
  def initialize(url, response)
    super('Request "%s" returned with status code "%s" and message "%s" and body "%s"' \
          %[url, response.code.to_s, response.message.to_s, response.body])
  end
end

class InvalidRequestError < Exception

end

class RequestHelper
  
  def initialize
    @@valid_request_types = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
  end

  def request(type, url, return_raw=false, valid_response_codes=[200, 201], **options)
    query = options[:query] || nil
    headers = options[:headers] || nil
    body = options[:body] || nil
    case type
    when 'GET'
      response = HTTParty.get(url, :query => query, :headers => headers)
    when 'POST'
      response = HTTParty.post(url, :query => query, :headers => headers, :body => body)
    when 'PUT'
      response = HTTParty.put(url, :query => query, :headers => headers, :body => body)
    when 'PATCH'
      response = HTTParty.patch(url, :query => query, :headers => headers, :body => body)
    when 'DELETE'
      response = HTTParty.delete(url, :query => query, :headers => headers)
    else
      raise InvalidRequestError, 'Invalid request type "%s". Valid types are "%s"' %[type, @@valid_request_types.join(',')] 
    end
    if !valid_response_codes.include? response.code
      raise RequestError.new(url, response)
    end
    return return_raw ? response : JSON.parse(response.body);
  end

end
