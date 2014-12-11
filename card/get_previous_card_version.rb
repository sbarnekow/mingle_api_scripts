require 'net/https'
require 'time'
require 'api-auth'
require 'json'

OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}
URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/projects/<project name>/cards/<card id>.xml'
PARAMS = {:version => '<card version you would like to get>'}

def http_get(url, options={}, params)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  body = params.to_json

  request = Net::HTTP::Get.new(uri.request_uri)
  request.body = body
  request['Content-Type'] = 'application/json'
  request['Content-Length'] = body.bytesize

  ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])

  response = http.request(request)
  cards = response.body

  if response.code.to_i > 300
    raise StandardError, <<-ERROR
    Request URL: #{url}
    Response: #{response.code}
    Response Message: #{response.message}
    Response Headers: #{response.to_hash.inspect}
    Response Body: #{response.body}
    ERROR
  end

  cards
end

puts http_get(URL, OPTIONS, PARAMS)