# 所属長承認申請の表示に関するヘルパーメソッド
module ApprovalRequestsHelper
  APPROVAL_STATUS_LABEL = {
    'pending' => '所属長承認申請中',
    'approved' => '所属長承認申請承認',
    'rejected' => '所属長承認申請否認'
  }.freeze

  # 指示者確認欄（status）の選択肢
  APPROVAL_STATUS_OPTIONS = [
    %w[なし none],
    %w[申請中 pending],
    %w[承認 approved],
    %w[否認 rejected]
  ].freeze

  # 所属長承認申請の状態に応じた表示ラベルを返す
  def approval_status_label(approval_request)
    APPROVAL_STATUS_LABEL[approval_request.status]
  end

  # 指示者確認欄のセレクト用選択肢を返す
  def approval_status_options
    APPROVAL_STATUS_OPTIONS
  end
end
