FactoryBot.define do
  factory :overtime_request do
    association :user
    association :superior, factory: :user
    worked_on { Date.new(2026, 2, 1) }
    scheduled_end_time { Time.zone.local(2026, 2, 1, 20) }
    status { :pending }
  end
end
