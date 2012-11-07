# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'rubygems'
require 'bundler'

Bundler.require(:default, :development, :test)

require 'wye'

RSpec.configure do |config|
  config.include RSpec::Matchers

  config.mock_with :rspec
end
