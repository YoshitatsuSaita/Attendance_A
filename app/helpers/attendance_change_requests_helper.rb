# 勤怠変更申請の表示に関するヘルパーメソッド
module AttendanceChangeRequestsHelper
  ATTENDANCE_CHANGE_STATUS_LABEL = {
    'pending' => '勤怠変更申請中',
    'approved' => '勤怠変更申請承認',
    'rejected' => '勤怠変更申請否認'
  }.freeze

  # 指示者確認欄（status）の選択肢
  ATTENDANCE_CHANGE_STATUS_OPTIONS = [
    %w[なし none],
    %w[申請中 pending],
    %w[承認 approved],
    %w[否認 rejected]
  ].freeze

  # 勤怠変更申請の状態に応じた表示ラベルを返す
  def attendance_change_status_label(change_request)
    ATTENDANCE_CHANGE_STATUS_LABEL[change_request.status]
  end

  # 指示者確認欄のセレクト用選択肢を返す
  def attendance_change_status_options
    ATTENDANCE_CHANGE_STATUS_OPTIONS
  end
end
