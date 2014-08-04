if defined?(RSpec)
  RSpec.configure do |config|
    config.include Virtus::Matchers
  end
end
