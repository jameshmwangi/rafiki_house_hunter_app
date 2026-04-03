FactoryBot.define do
  factory :property_comment do
    listing { nil }
    author { nil }
    parent_comment { nil }
    body { "MyText" }
  end
end
