Dir[File.expand_path('../../spec/{helpers,support}/*.rb', __FILE__)].each do |f|
  require f
end

Schema.create

require 'valium'