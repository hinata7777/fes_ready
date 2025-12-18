FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "Artist #{n}" }
    published { true }
    uuid { SecureRandom.uuid }
  end
end
