Flipper.configure do |config|
  config.adapter { Flipper::Adapters::ActiveRecord.new }
end
