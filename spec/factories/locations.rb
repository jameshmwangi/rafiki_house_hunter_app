FactoryBot.define do
  factory :location do
    sequence(:area_name) { |n| "Area #{n}" }
    county { "Nairobi" }
    country { "Kenya" }
  end
end
