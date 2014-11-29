require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'


URL = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/projects/test_project/property_definitions.xml'
OPTIONS = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}
PARAMS = {
  :property_definition => {
    :name => 'Story Status',
    :data_type => 'String',
    :is_managed => 'true',
    :card_types => [{name: 'Story'}]
  }
}

def http_post(url, params, options={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      if options[:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    body = params.to_json

    puts body
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = body

    request['Content-Type'] = 'application/json'
    request['Content-Length'] = body.bytesize

    if options[:access_key_id]
      ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    end

    response = http.request(request)

    if response.code.to_i > 300
      raise StandardError, <<-ERROR
      \nRequest URL: #{url}
      Response: #{response.code} #{response.message}
      Response Headers: #{response.to_hash.inspect}\nResponse Body: #{response.body}
      ERROR
  end
end

puts http_post(URL, PARAMS, OPTIONS)