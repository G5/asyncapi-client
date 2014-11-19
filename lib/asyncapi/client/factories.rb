factories_dir = File.expand_path("../../../../spec/factories/*.rb", __FILE__)
Dir[factories_dir].each { |f| require f }
