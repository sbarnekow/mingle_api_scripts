require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

PARAMS = {
  :mql => "SELECT Number, Name where Status = Done"
}

def http_get(url, params, options={})
    p params

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

    if options[:access_key_id]
      ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    end

    response = http.request(request)

    card = response.body

    p card

    if response.code.to_i > 300
      raise StandardError, <<-ERROR
      Request URL: #{url}
      Response: #{response.code}
      Response Message: #{response.message}
      Response Headers: #{response.to_hash.inspect}
      Response Body: #{response.body}
      ERROR
  end
end

http_get(URL, PARAMS, OPTIONS)