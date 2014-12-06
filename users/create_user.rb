require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/users.xml'
OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}
PARAMS = { :user => 
  { :name => "Bob", 
    :login => "bob_lob",
    :email => "bob_lob@thoughtworks.com",
    :password => "BobLobR0ckz!",
    :password_confirmation => "BobLobR0ckz!",
    :admin => "true"
  }
}

def http_post(url, params, options={})
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  body = params.to_json

  request = Net::HTTP::Post.new(uri.request_uri)
  request.body = body
  request['Content-Type'] = 'application/json'
  request['Content-Length'] = body.bytesize
  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
  user = http.request(request)

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
      Request URL: #{url}
      Response: #{response.code}
      Response Message: #{response.message}
      Response Headers: #{response.to_hash.inspect}
      Response Body: #{response.body}
      ERROR
  end
  user
end

http_post(URL, PARAMS, OPTIONS)
