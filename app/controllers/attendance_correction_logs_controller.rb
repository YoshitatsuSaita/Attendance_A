# 本人の承認済み勤怠修正履歴を表示するコントローラー
class AttendanceCorrectionLogsController < ApplicationController
  before_action :logged_in_user
  before_action :not_admin

  # 年・月で絞り込んだ自分の修正履歴を対象日ごとに集約して表示する
  def index
    @selected_year = params[:year].presence
    @selected_month = params[:month].presence
    @recorded_years = current_user.attendance_correction_logs.recorded_years
    @histories = filtered_logs.aggregated_history
  end

  private

  # 選択された年・月で自分の修正ログを絞り込む（未選択の条件は無視）
  def filtered_logs
    logs = current_user.attendance_correction_logs
    logs = logs.in_year(@selected_year) if @selected_year
    logs = logs.in_month(@selected_month) if @selected_month
    logs
  end
end
