# 勤怠変更申請の作成を管理するコントローラー
class AttendanceChangeRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :not_admin

  def create
    ActiveRecord::Base.transaction do
      change_request_rows.each do |id, item|
        attendance = current_user.attendances.find(id)
        build_change_request(attendance, item).save!
      end
    end
    flash[:success] = '勤怠変更申請を送信しました。'
    redirect_to user_url(current_user, date: params[:date], mode: params[:mode])
  rescue ActiveRecord::RecordInvalid => e
    flash[:danger] = e.record.errors.full_messages.join('<br>')
    redirect_to attendances_edit_one_month_user_url(current_user,
                                                    date: params[:date],
                                                    mode: params[:mode])
  end

  private

  # 指示者確認欄が空欄の行は申請対象外とする
  def change_request_rows
    attendances_params.select { |_id, item| item[:superior_id].present? }
  end

  def build_change_request(attendance, item)
    current_user.attendance_change_requests.build(
      superior_id: item[:superior_id],
      worked_on: attendance.worked_on,
      before_started_at: attendance.started_at,
      before_finished_at: attendance.finished_at,
      started_time: item[:started_at],
      finished_time: item[:finished_at],
      next_day: item[:next_day],
      note: item[:note],
      status: :pending
    )
  end

  def attendances_params
    params.require(:user).permit(
      attendances: %i[started_at finished_at next_day note superior_id]
    )[:attendances]
  end
end
