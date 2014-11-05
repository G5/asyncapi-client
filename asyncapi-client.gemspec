$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "asyncapi/client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "asyncapi-client"
  s.version     = Asyncapi::Client::VERSION
  s.authors     = ["Marc Ignacio", "Ramon Tayag"]
  s.email       = ["marc@aelogica.com", "ramon@aelogica.com"]
  s.homepage    = "http://github.com/g5search/noneyet"
  s.summary     = "Asynchronous API communication"
  s.description = "Asynchronous API communication"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.1.5"
  s.add_dependency "sidekiq"
  s.add_dependency "kaminari"
  s.add_dependency "api-pagination"
  s.add_dependency "typhoeus"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "pry"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "database_cleaner"
end
