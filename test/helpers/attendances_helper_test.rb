require 'test_helper'

class AttendancesHelperTest < ActionView::TestCase
  # ここにテストを書く
  test '日曜日は sunday を返す' do
    assert_equal 'sunday', weekday_color(Date.new(2026, 4, 12))
  end

  test '土曜日は saturday を返す' do
    assert_equal 'saturday', weekday_color(Date.new(2026, 4, 11))
  end

  test '平日は nil を返す' do
    assert_nil weekday_color(Date.new(2026, 4, 10))
  end

  test '17分は15に丸められる' do
    time = Time.zone.local(2026, 4, 11, 9, 17)
    assert_equal '15', format_quarter_hour(time)
  end
end
