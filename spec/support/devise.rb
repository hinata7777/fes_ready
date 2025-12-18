RSpec.configure do |config|
  # Devise のログインヘルパーをリクエストスペックで使う
  config.include Devise::Test::IntegrationHelpers, type: :request
end
