require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<MINGLE INSTANCE NAME>.mingle-api.thoughtworks.com/api/v2/projects/<PROJECT NAME>/feeds/events.xml?page=3 rel="next"'

OPTIONS = {:access_key_id => '<SIGN IN NAME>', :access_secret_key => '<TOKEN>'}

def http_get(url, options={})
  uri = URI.parse(URI.encode(url.strip))
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  
  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  events = response.body

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
    Request URL: #{url}
    Response: #{response.code}
    Response Message: #{response.message}
    Response Headers: #{response.to_hash.inspect}
    Response Body: #{response.body}
    ERROR
  end

  puts events 
end

http_get(URL, OPTIONS)