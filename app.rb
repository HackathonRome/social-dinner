require 'sinatra'

require File.join(File.dirname(__FILE__), 'config', 'yummly.rb') unless ENV['RACK_ENV'] == 'production'

def base_uri
  'http://api.yummly.com/v1/api/'
end

def authorization_params
  { _app_id: ENV['YUMMLY_APP_ID'], _app_key: ENV['YUMMLY_APP_KEY'] }
end

def generate_uri_for(endpoint)
  uri = URI("#{base_uri}#{endpoint}")
  uri.query = URI.encode_www_form(authorization_params)
  uri
end

def clean_json_response(response, resource)
  response.gsub(/set_metadata\(\'#{resource}\'\,/, '').gsub(/\);$/, '')
end

def cache_data(filename, data)
  File.open(File.join(File.dirname(__FILE__), 'public', filename), "w") do |cache_file|
    cache_file.write data
  end
end

get '/courses' do
  uri = generate_uri_for('metadata/course')
  result = Net::HTTP.get_response(uri)
  courses = clean_json_response(result.body, 'course')
  courses = "{ \"courses\": #{courses} }"
  cache_data('courses.json', courses)
  courses
end
