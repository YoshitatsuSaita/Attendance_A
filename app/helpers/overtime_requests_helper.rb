# 残業申請の表示に関するヘルパーメソッド
module OvertimeRequestsHelper
  OVERTIME_STATUS_LABEL = {
    'pending' => '残業申請中',
    'approved' => '残業申請承認',
    'rejected' => '残業申請否認'
  }.freeze

  # 指示者確認欄（status）の選択肢
  OVERTIME_STATUS_OPTIONS = [
    %w[なし none],
    %w[申請中 pending],
    %w[承認 approved],
    %w[否認 rejected]
  ].freeze

  # 残業申請の状態に応じた表示ラベルを返す
  def overtime_status_label(overtime_request)
    OVERTIME_STATUS_LABEL[overtime_request.status]
  end

  # 指示者確認欄のセレクト用選択肢を返す
  def overtime_status_options
    OVERTIME_STATUS_OPTIONS
  end

  # 分を H:MM 形式の時間外時間表記に変換する
  def format_overtime_duration(minutes)
    format('%<h>d:%<m>02d', h: minutes / 60, m: minutes % 60)
  end
end
