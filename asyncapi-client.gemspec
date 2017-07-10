$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "asyncapi/client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "asyncapi-client"
  s.version     = Asyncapi::Client::VERSION
  s.authors     = ["G5", "Marc Ignacio", "Ramon Tayag"]
  s.email       = ["lateam@getg5.com", "marcrendlignacio@gmail.com", "ramon.tayag@gmail.com"]
  s.homepage    = "https://github.com/G5/asyncapi-client"
  s.summary     = "Asynchronous API communication"
  s.description = "Asynchronous API communication"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,spec/factories}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "sidekiq", "~> 4.2.10"
  s.add_dependency "sidekiq-cron", "0.6.3"
  s.add_dependency "kaminari", "~> 1.0.1"
  s.add_dependency "api-pagination", "~> 4.6.3"
  s.add_dependency "typhoeus", "~> 1.1.2"
  s.add_dependency "aasm", ">= 4.0"
  s.add_dependency "ar_after_transaction"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "pry"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "rspec-sidekiq"
  s.add_development_dependency "timecop"
end
