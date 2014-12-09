require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'nokogiri'

def ask_for_url
  puts "What is the full (including http:// or https://) url of your instance?"
  url = gets.chomp
  url 
end

def ask_for_username
  puts "What is your admin username?"
  username = gets.chomp
  username
end

def ask_for_password
  puts "What is your admin password?"
  password = gets.chomp
  password
end

def http_get(url, username, password)
    users_url = url + "/api/v2/users.xml"
    uri = URI.parse(users_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(username, password_
    response = http.request(request)
    response
end

def parse(response)
  xml = Nokogiri::XML(response.body)
  user_ids = []
  xml.css('user').each {|user| user_ids << user.at_css('id').content }
  user_ids.sort!
end

def ask_for_id(user_arr)
  puts "What's the user ID of the user updating?"
  admin = gets.chomp
  user_arr.delete_if{|x| x == admin }
end

def http_put(url, username, password, user_array)
  user_array.each do |user|
    params = { :user => { :activated => "false" } }
    concatenated_url = url + '/api/v2/users/' + user + '.xml'

    uri = URI.parse(concatenated_url)
    http = Net::HTTP.new(uri.host, uri.port)
    body = params.to_json

    request = Net::HTTP::Put.new(uri.request_uri)
    p request.body
    request.body = body
    request['Content-Type'] = 'application/json'
    request['Content-Length'] = body.bytesize
    request.basic_auth(username, password)
    response = http.request(request)
    p response.body
  end
end

url = ask_for_url
username = ask_for_username
password = ask_for_password
users = http_get(url, username, password)
user_id_array = parse(users)
correct_arr = ask_for_id(user_id_array)
http_put(url, username, password, correct_arr)
