require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test '未来日の勤怠は update できない' do
    attendance = Attendance.new(worked_on: Date.tomorrow, user: users(:archer))
    assert_not attendance.valid?(:update)
  end

  test '今日の勤怠は update できる' do
    attendance = Attendance.new(worked_on: Time.zone.today,
                                user: users(:archer))
    assert attendance.valid?(:update)
  end

  test 'started_at なしで finished_at だけある時invalid' do
    attendance = Attendance.new(
      worked_on: Time.zone.today,
      user: users(:archer),
      started_at: nil, # 空にしたい
      finished_at: Time.current
    )
    assert_not attendance.valid?
  end

  test 'finished_at が started_at より早い時invalid' do
    attendance = Attendance.new(
      worked_on: Time.zone.today,
      user: users(:archer),
      started_at: Time.current,
      finished_at: 1.hour.ago # started_at より早い時刻にしたい
    )
    assert_not attendance.valid?
  end
end
