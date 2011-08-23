Dir[File.expand_path('../{helpers,support}/*.rb', __FILE__)].each do |f|
  require f
end

RSpec.configure do |config|
  config.before(:suite) do
    puts '=' * 80
    puts "Running specs against ActiveRecord #{ActiveRecord::VERSION::STRING}..."
    puts '=' * 80
    Schema.create
  end

  config.include ValiumHelper
end

require 'valium'