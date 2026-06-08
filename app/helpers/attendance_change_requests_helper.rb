# 勤怠変更申請の表示に関するヘルパーメソッド
module AttendanceChangeRequestsHelper
  ATTENDANCE_CHANGE_STATUS_LABEL = {
    'pending' => '勤怠変更申請中',
    'approved' => '勤怠変更申請承認',
    'rejected' => '勤怠変更申請否認'
  }.freeze

  # 勤怠変更申請の状態に応じた表示ラベルを返す
  def attendance_change_status_label(change_request)
    ATTENDANCE_CHANGE_STATUS_LABEL[change_request.status]
  end
end
