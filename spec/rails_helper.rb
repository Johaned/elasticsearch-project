# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Configure Capybara
Capybara.default_host = "http://127.0.0.1"
Capybara.javascript_driver = :webkit
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers => { 'HTTP_USER_AGENT' => 'Capybara' })
end

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # DatabaseCleaner config
  static_info_tables = %w[]

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation, {except: static_info_tables}
    DatabaseCleaner.start
    DatabaseCleaner.clean
  end

  config.before(:context) do |example|
    DatabaseCleaner.clean
  end

  config.before(:example) do |example|
    DatabaseCleaner.clean unless example.metadata[:keep_db]
  end

  # Exclude options
  config.filter_run_excluding :exclude => true

  # Factory Girl methods
  config.include FactoryGirl::Syntax::Methods
  # Kind of hack for zeus
  # You can also use commands below
  #FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
  #FactoryGirl.find_definitions
  config.before(:all) do
    FactoryGirl.reload
  end

  # Include devise test helpers in controller specs
  config.include Devise::TestHelpers, :type => :controller

  # Include mongoid matches in model specs
  config.include Mongoid::Matchers, type: :model

  config.include Capybara::DSL

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
