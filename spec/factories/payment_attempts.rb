FactoryBot.define do
  factory :payment_attempt do
    viewing_appointment { nil }
    payment_method { "MyString" }
    outcome { "MyString" }
    payment_reference { "MyString" }
  end
end
