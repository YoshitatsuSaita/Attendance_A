# 勤怠変更申請に退社時間（変更前・変更後）の列を追加する
class AddFinishedAtToAttendanceChangeRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :attendance_change_requests, :before_finished_at, :datetime
    add_column :attendance_change_requests, :after_finished_at, :datetime
  end
end
