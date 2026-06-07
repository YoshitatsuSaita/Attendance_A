# 残業申請の表示に関するヘルパーメソッド
module OvertimeRequestsHelper
  OVERTIME_STATUS_LABEL = {
    'pending' => '残業申請中',
    'approved' => '残業申請承認',
    'rejected' => '残業申請否認'
  }.freeze

  # 残業申請の状態に応じた表示ラベルを返す
  def overtime_status_label(overtime_request)
    OVERTIME_STATUS_LABEL[overtime_request.status]
  end
end
