require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'nokogiri'

all_users_url = 'https://sarahh.mingle-api.thoughtworks.com/api/v2/users.xml'
keys = {:access_key_id => 'sbarnek_hello', :access_secret_key => 'BXXorZ+L+WmijXMSVwMtZBH2OnqQn/bFAVbeluN+IVY='}

def make_request(url, method, params, keys={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    
    if uri.scheme == 'https'
      http.use_ssl = true
      if keys[:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    if method == 'get'
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      all_projects = response.body

      output = File.open("users.xml", "w")
      output << all_projects
      output.close
    
    elsif method == 'put'
      body = params.to_json
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = body
    
    end

    response = http.request(request)

    if keys[:access_key_id]
      ApiAuth.sign!(request, keys[:access_key_id], keys[:access_secret_key])
    end

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

def count_user_objects
  users_document = Nokogiri::XML(open('users.xml')) { |c| c.noblanks } 

  return users_document.root.children.count
end

def update_each_user(keys)
    url = 'https://sarahh.mingle-api.thoughtworks.com/api/v2/users/21.xml'
    params = {
      :user => {
        :name => 'sarah_changed',
        :activated => 'false'
      }
    }
    puts url
    puts params
    puts keys
    p make_request(url, 'put', params, keys)
  
end

update_each_user(keys)