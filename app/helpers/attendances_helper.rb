module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil? 
    end 
      return '退勤' if attendance.started_at.present? &&
                      attendance.finished_at.nil? && 
                      attendance.worked_on >= Date.yesterday
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    rounded_start  = start.change(min: format_quarter_hour(start), sec: 0)
    rounded_finish = finish.change(min: format_quarter_hour(finish), sec: 0)
    format("%.2f", (((rounded_finish - rounded_start) / 60) / 60.0))
  end

  # 曜日の情報を受け取り、土日の場合該当のクラス情報を付与します。
  def weekday_color(date)
    if date.wday == 0
      "sunday"
    elsif date.wday == 6
      "saturday"
    end

  end

# 現在の時刻の分を受け取り、15の倍数ごとに表記を変えます。
  def format_quarter_hour(time)
    format("%02d", (time.min / 15) * 15)
  end
end
