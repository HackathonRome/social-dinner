ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'sinatra'
require 'rspec'
require 'rack/test'
require 'capybara'
require 'capybara/dsl'
require File.join(File.dirname(__FILE__), '..', 'app.rb')

Capybara.app = Sinatra::Application

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Capybara::DSL
end

def app
  @app ||= Sinatra::Application
end
