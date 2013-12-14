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

    def get_menu params
      uri = generate_uri_for('recipes', params)
      Net::HTTP.get_response(uri)
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
      uri.query = URI.encode_www_form(prepare_params(additional_params))
      p uri
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
  users = JSON.parse File.read File.join('cache', 'users.json')
  users_attributes = users['users'].select{ |k| friends.include? k }

  # ?excludedCuisine[]=ita&excludedCuisine[]=fra&allowedHolidays[]=asd&

  api_params_keys =
    %w(excludedIngredient excludedCuisine)
  api_params = Hash[ api_params_keys.map{ |v| [ "#{v}[]", [] ] } ]

  users_attributes.each_value do |attributes|
    api_params_keys.each do |k|
      api_params["#{k}[]"] = api_params["#{k}[]"] | attributes[k]
    end
  end
  
  api_params['allowedHoliday[]'] = holidays

  complete_response = { recipes: {
      'Main Dishes' => [],
      'Desserts' => [],
      'Side Dishes' => [],
      'Appetizers' => []
    }
  }

  courses.each do |course|
    api_params['allowedCourse[]']  = courses  
    result = YUMMLY::Client.new.get_menu api_params

    course_key = course.gsub('course^course-', '')
    JSON.parse(result.body.force_encoding('UTF-8'))['matches'].each do |recipe|
      complete_response[:recipes][course_key] << {
        id: recipe['id'],
        name: recipe['recipeName'],
        ingredients: recipe['ingredients'],
        thumbnail: recipe['smallImageUrls']
      }
    end
  end

  complete_response.to_json
end

get '/friends/:email' do |email|
  File.read(File.join('cache', 'friends_list.json'))
end
