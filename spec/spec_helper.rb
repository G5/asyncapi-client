ENV["RAILS_ENV"] ||= "test"
SPEC_DIR = File.dirname(__FILE__)
DUMMY_DIR = File.join(SPEC_DIR, "dummy")

require File.join(DUMMY_DIR, "config", "environment")
require "dummy/config/environment"
require "rspec/rails"
require "rspec/its"
require "factory_girl"
require "database_cleaner"
require "pry"

Dir[
  File.join(SPEC_DIR, "support", "**", "*.rb"),
  File.join(SPEC_DIR, "factories", "*.rb"),
  File.join(SPEC_DIR, "fixtures", "*.rb"),
].each {|f| require f}

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

end
