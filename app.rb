require 'sinatra'
require 'net/http'
require 'active_support/inflector'
require 'json'

require File.join(File.dirname(__FILE__), 'config', 'yummly.rb') unless ENV['RACK_ENV'] == 'production'

module YUMMLY
  class Client
    def get_metadata_for(resource)
      uri = generate_uri_for("metadata/#{resource}")
      result = Net::HTTP.get_response(uri)
      data = clean_json_response(result.body, resource)
      resources = resource.pluralize
      data = "{ \"#{resources}\": #{data} }"
      cache_data("#{resources}.json", data)
      data
    end

    def get_menu
      uri = generate_uri_for("recipes")
      result = Net::HTTP.get_response(uri)
      data = "{ \"response\": #{result.body} }"
      data
    end

  private

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
  end
end

get '/' do
    apis = {
      "/allergies.json" => "GET the list of available allergies",
      "/courses.json" => "GET the list of available courses",
      "/cuisines.json" => "GET the list of available cuisines",
      "/holidays.json" => "GET the list of available holidays",
      "/ingredients.json" => "GET the list of available ingredients"
    }.to_json
    "{\"apis\": #{apis} }"
end

%w[allergy course cuisine holiday ingredient].each do |metadata|
  get "/#{metadata.pluralize}" do
    YUMMLY::Client.new.get_metadata_for metadata
  end
end

get '/menu/:email' do |email|
  "{ \"error\": \"You must specify a list of friends.\" }"
end

get '/friends/:email' do |email|
  #redirect to('/friends.json')
end