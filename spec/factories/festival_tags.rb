FactoryBot.define do
  factory :festival_tag do
    sequence(:name) { |n| "Tag #{n}" }
  end
end
