require 'sinatra'
require 'net/http'
require 'active_support/inflector'

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

get '/courses' do
  YUMMLY::Client.new.get_metadata_for 'course'
end

get '/ingredients' do
  YUMMLY::Client.new.get_metadata_for 'ingredient'
end

get '/allergies' do
  YUMMLY::Client.new.get_metadata_for 'allergy'
end
