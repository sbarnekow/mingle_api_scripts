require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/projects/test_project/murmurs.xml'
OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}
PARAMS = { :before_id => "41" }

def http_get(url, options={}, params)
    uri = URI.parse(url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    if uri.scheme == 'https'
      http.use_ssl = true
      if options[:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    body = params.to_json

    request = Net::HTTP::Get.new(uri.request_uri)
    request.body = body
    request['Content-Type'] = 'application/json'
    request['Content-Length'] = body.bytesize
    
    if options[:access_key_id]
      ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    end

    response = http.request(request)

    if response.code.to_i > 300
      raise StandardError, <<-ERROR
      Request URL: #{url}
      Response: #{response.code}
      Response Message: #{response.message}
      Response Headers: #{response.to_hash.inspect}
      Request Body : #{request.body}
      Response Body: #{response.body}
      ERROR
  end
end

http_get(URL, OPTIONS, PARAMS)