require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/projects.xml'
OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}

def http_get(url, options={})
    uri = URI.parse(url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    if uri.scheme == 'https'
      http.use_ssl = true
      if options[:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    request = Net::HTTP::Get.new(uri.request_uri)


    if options[:access_key_id]
      ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    end

    response = http.request(request)

    project = response.body

    puts project

    if response.code.to_i > 300
      raise UnexpectedResponseError, <<-ERROR
      \nRequest URL: #{url}
      Response: #{response.code} #{response.message}
      Response Headers: #{response.to_hash.inspect}\nResponse Body: #{response.body}"
      ERROR
  end
end

http_get(URL, OPTIONS)