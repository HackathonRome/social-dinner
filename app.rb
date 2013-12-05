require 'sinatra'

require File.join(File.dirname(__FILE__), 'config', 'yummly.rb') unless ENV['RACK_ENV'] == 'production'

get '/courses' do
  uri = URI('http://api.yummly.com/v1/api/metadata/course')
  params = { _app_id: ENV['YUMMLY_APP_ID'], _app_key: ENV['YUMMLY_APP_KEY'] }
  uri.query = URI.encode_www_form(params)

  result = Net::HTTP.get_response(uri)
  courses = result.body.gsub(/set_metadata\(\'course\'\,/, '').gsub(/\);$/, '')
  "{ \"courses\": #{courses} }"
end
