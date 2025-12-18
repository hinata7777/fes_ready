FactoryBot.define do
  factory :festival_festival_tag do
    association :festival, strategy: :create
    association :festival_tag, strategy: :create
  end
end
