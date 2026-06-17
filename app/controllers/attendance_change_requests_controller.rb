# 勤怠変更申請の作成を管理するコントローラー
class AttendanceChangeRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :not_admin
  before_action :superior_user, only: %i[received review]

  # 上長宛ての申請中・否認済みの勤怠変更申請（お知らせ）を申請者ごとに表示する
  def received
    @change_requests_by_user =
      current_user.received_attendance_change_requests
                  .where(status: %i[pending rejected])
                  .includes(:user)
                  .order(:worked_on)
                  .group_by(&:user)
    render partial: 'attendance_change_requests/received'
  end

  # 変更チェックの付いた行のみ指示者確認欄（status）を反映する
  def review
    apply_review(current_user.received_attendance_change_requests,
                 review_params, '勤怠変更申請')
    redirect_to user_url(current_user, date: params[:date])
  end

  def create
    ActiveRecord::Base.transaction do
      change_request_rows.each do |id, item|
        attendance = current_user.attendances.find(id)
        current_user.attendance_change_requests
                    .where(worked_on: attendance.worked_on)
                    .where(status: %i[pending rejected])
                    .destroy_all
        build_change_request(attendance, item).save!
      end
    end
    flash[:success] = '勤怠変更申請を送信しました。'
    redirect_to user_url(current_user, date: params[:date])
  rescue ActiveRecord::RecordInvalid => e
    flash[:danger] = e.record.errors.full_messages.join('<br>')
    redirect_to attendances_edit_one_month_user_url(current_user,
                                                    date: params[:date])
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

  def review_params
    params.permit(attendance_change_requests: %i[status apply])
          .fetch(:attendance_change_requests, {})
  end
end
