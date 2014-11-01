require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'nokogiri'

all_users_url = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/users.xml'
keys = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}

def http_get(url, keys={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    
    if uri.scheme == 'https'
      http.use_ssl = true
      if keys[:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    all_projects = response.body

    if keys[:access_key_id]
      ApiAuth.sign!(request, keys[:access_key_id], keys[:access_secret_key])
    end

    response = http.request(request)

    if response.code.to_i > 300
        raise StandardError, <<-ERROR
        Request URL: #{url}
        Response: #{response.code}
        Response Message: #{response.message}
        Response Headers: #{response.to_hash.inspect}
        Response Body: #{response.body}
        ERROR
    end

    return response
end

def parse(response)
  xml = Nokogiri::XML(response.body)
  user_ids = []
  xml.css('user').each {|user| user_ids << user.at_css('id').content }
  return user_ids.sort!
end

def http_put(user_array)
  user_array.delete_if{|x| x == "1"}

  user_array.each do |user|
    url = 'https://<instance name>.mingle-api.thoughtworks.com/api/v2/' + user.to_i + '.xml'
    keys = {:access_key_id => '<MINGLE USERNAME>', :access_secret_key => '<MINGLE HMAC KEY>'}
    params = { :user => { :admin => false, :activated => false } }

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      if [:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
    body = params.to_json

    request = Net::HTTP::Put.new(uri.request_uri)
    request.body = body

    request['Content-Type'] = 'application/json'
    request['Content-Length'] = body.bytesize


    if keys[:access_key_id]
      ApiAuth.sign!(request, keys[:access_key_id], keys[:access_secret_key])
    end

    response = http.request(request)

    if response.code.to_i > 300
        raise StandardError, <<-ERROR
        Request URL: #{url}
        Response: #{response.code}
        Response Message: #{response.message}
        Response Headers: #{response.to_hash.inspect}
        Response Body: #{response.body}
        ERROR
    end

    return response
  end
end

# def update_each_user(user_arr, current_user_id)
#     user_arr.delete_if{|x| x == current_user_id}
#     user_arr.each do |user|
#       url = 'https://sarahh.mingle-api.thoughtworks.com/api/v2/users/' + user + '.xml'
#       keys = {:access_key_id => 'admin', :access_secret_key => 'kRSr/Tv++vQDWyrwh8eGJLS3JvSFDr41AQcHq/sPq0c='}
#       params = { :user => { :activated => false } }
#       make_request(url, 'put', params, keys)
#     end
# end

response = http_get(all_users_url, keys)
user_id_array = parse(response)
http_put(user_id_array)
