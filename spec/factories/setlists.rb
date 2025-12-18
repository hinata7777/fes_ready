FactoryBot.define do
  factory :setlist do
    association :stage_performance, strategy: :create
    uuid { SecureRandom.uuid }
  end
end
