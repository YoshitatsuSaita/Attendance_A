# 勤怠修正履歴ページに関するヘルパーメソッド
module AttendanceCorrectionLogsHelper
  # 月の絞り込みプルダウンの選択肢（1〜12月）を返す
  def correction_log_month_options
    (1..12).map { |month| [t('date.month_names')[month], month] }
  end
end
