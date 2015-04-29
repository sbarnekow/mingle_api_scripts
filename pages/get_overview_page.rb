require 'net/https'
require 'time'
require 'api-auth'
require 'json'

URL = 'https://<MINGLE INSTANCE>.mingle-api.thoughtworks.com/api/v2/projects/<PROJECT/wiki/Overview_Page.xml'
# To get other wiki pages, find the page identifier such as "Overview_Page" at https://<Mingle Instance>.mingle-api.thoughtworks.com/api/v2/projects/<project name>/wiki.xml
OPTIONS = {:access_key_id => <'LOGIN NAME'>, :access_secret_key => <'HMAC SECRET KEY'>}

def http_get(url, options={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri.request_uri)
    ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    
    response = http.request(request)
    result = response.body
    
    if response.code.to_i > 300
        raise StandardError, <<-ERROR
        Request URL: #{url}
        Response: #{response.code}
        Response Message: #{response.message}
        Response Headers: #{response.to_hash.inspect}
        Response Body: #{response.body}
        ERROR
    end
    
    p result
end

http_get(URL, OPTIONS)