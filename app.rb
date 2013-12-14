require 'sinatra'
require 'net/http'
require 'active_support/inflector'
require 'json'

require File.join(File.dirname(__FILE__), 'config', 'yummly.rb') unless ENV['RACK_ENV'] == 'production'

module YUMMLY
  class Client
    def get_metadata_for(resource)
      resources = resource.pluralize
      filename = "#{resources}.json"
      filepath = File.join 'cache', filename
      return File.read filepath if File.exists? filepath

      uri = generate_uri_for("metadata/#{resource}")
      result = Net::HTTP.get_response(uri)
      data = clean_json_response(result.body, resource)
      data = "{ \"#{resources}\": #{data} }"

      cache_data(filename, data)
      data
    end

  private

    def base_uri
      'http://api.yummly.com/v1/api/'
    end

    def prepare_params(additional_params = {})
      authorization_params.merge additional_params
    end

    def authorization_params
      { _app_id: ENV['YUMMLY_APP_ID'], _app_key: ENV['YUMMLY_APP_KEY'] }
    end

    def generate_uri_for(endpoint, additional_params = {})
      uri = URI("#{base_uri}#{endpoint}")
      uri.query = URI.encode_www_form(prepare_params, additional_params)
      uri
    end

    def clean_json_response(response, resource)
      response.gsub(/set_metadata\(\'#{resource}\'\,/, '').gsub(/\);$/, '')
    end

    def cache_data(filename, data)
      File.open(File.join(File.dirname(__FILE__), 'cache', filename), "w") do |cache_file|
        cache_file.write data
      end
    end
  end
end

def are_friends_specified?
  params[:friends] && params[:friends].any?
end

before do
  headers \
    "Access-Control-Allow-Origin" => "*",
    "Content-Type" => "application/json"
end

get '/' do
    { apis: 
      {
        "/allergies" => "GET the list of available allergies",
        "/courses" => "GET the list of available courses",
        "/cuisines" => "GET the list of available cuisines",
        "/holidays" => "GET the list of available holidays",
        "/ingredients" => "GET the list of available ingredients"
      }
    }.to_json
end

%w[allergy course cuisine holiday ingredient].each do |metadata|
  get "/#{metadata.pluralize}" do
    YUMMLY::Client.new.get_metadata_for metadata
  end
end

get '/menu/:email' do |email|
  return { error: "You must specify a list of friends." }.to_json unless are_friends_specified?

  default_courses = [ "course^course-Main Dishes" , 
                      "course^course-Desserts"    , 
                      "course^course-Side Dishes" , 
                      "course^course-Appetizers"  ]
  friends = params[:friends]
  holidays = params[:holiday] ? [ params[:holiday] ] : []
  courses = params[:courses] || default_courses
  users_json = JSON.parse File.read File.join('cache', 'users.json')
  users_attributes = users['users'].select{ |k| friends.include? k }

  # ?excludedCuisine[]=ita&excludedCuisine[]=fra&allowedHolidays[]=asd&

  friends_attributes_keys =
    %(allowedIngredients excludedIngredients allowedCuisine excludedCuisine)
  friends_attributes = Hash[ friends_attributes_keys.map{ |v| [ v, [] ] } ]

  users['users'].select{ |k| friends.include? k }.each_value do |attributes|
    friends_attributes.keys.each do |k|
      friends_attributes[k] = friends_attributes[k] | attributes[k]
    end
  end
  friends_attributes['allowedCourses']  = courses
  friends_attributes['allowedHolidays'] = holidays

  friends_attributes

  uri = generate_uri_for('menu', friends_attributes)
  result = Net::HTTP.get_response(uri)
  { response: result.body.force_encoding('UTF-8') }.to_json
end

get '/friends/:email' do |email|
  File.read(File.join('cache', 'friends_list.json'))
end
