require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'aftership_endpoint')

Dir[File.join(File.dirname(__FILE__), 'support', '**/*.rb')].each {|f| require f}

require 'spree/testing_support/controllers'
require 'webmock/rspec'


Sinatra::Base.environment = 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
  config.include WebStubs
end
