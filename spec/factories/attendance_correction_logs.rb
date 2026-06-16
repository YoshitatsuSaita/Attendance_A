FactoryBot.define do
  factory :attendance_correction_log do
    association :user
    association :approver, factory: :user
    worked_on { Date.new(2026, 2, 1) }
    before_started_at { Time.zone.local(2026, 2, 1, 10) }
    before_finished_at { Time.zone.local(2026, 2, 1, 18) }
    after_started_at { Time.zone.local(2026, 2, 1, 11) }
    after_finished_at { Time.zone.local(2026, 2, 1, 19) }
  end
end
