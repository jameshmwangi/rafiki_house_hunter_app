FactoryBot.define do
  factory :viewing_appointment do
    listing { nil }
    home_seeker { nil }
    agent { nil }
    scheduled_at { "2026-03-27 22:15:32" }
    fee_amount { 1 }
    fee_status { "MyString" }
    status { "MyString" }
  end
end
