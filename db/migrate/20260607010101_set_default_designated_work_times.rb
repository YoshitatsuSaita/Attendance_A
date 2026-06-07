# 指定勤務開始・終了時間に既定値（09:00 / 18:00）を設定する
class SetDefaultDesignatedWorkTimes < ActiveRecord::Migration[7.1]
  # datetime カラムは UTC 保存・Asia/Tokyo 表示のため、
  # JST の 09:00 / 18:00 を Time.zone 経由で生成する
  DEFAULT_START = Time.find_zone('Asia/Tokyo').local(2000, 1, 1, 9, 0)
  DEFAULT_END = Time.find_zone('Asia/Tokyo').local(2000, 1, 1, 18, 0)

  def up
    change_column_default :users, :designated_work_start_time, DEFAULT_START
    change_column_default :users, :designated_work_end_time, DEFAULT_END
    User.where(designated_work_start_time: nil)
        .update_all(designated_work_start_time: DEFAULT_START)
    User.where(designated_work_end_time: nil)
        .update_all(designated_work_end_time: DEFAULT_END)
  end

  def down
    change_column_default :users, :designated_work_start_time, nil
    change_column_default :users, :designated_work_end_time, nil
  end
end
