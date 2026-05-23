# 勤怠情報の登録・編集を管理するコントローラー
class AttendancesController < ApplicationController
  before_action :set_user, only: %i[edit_one_month update_one_month]
  before_action :logged_in_user, only: %i[update edit_one_month]
  before_action :admin_or_correct_user,
                only: %i[update edit_one_month update_one_month]
  before_action :set_attendance_period, only: :edit_one_month

  UPDATE_ERROR_MSG = '勤怠登録に失敗しました。やり直してください。'.freeze

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update(started_at: Time.current.change(sec: 0))
        flash[:info] = 'おはようございます！'
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update(finished_at: Time.current.change(sec: 0))
        flash[:info] = 'お疲れ様でした。'
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
    @attendances.each do |attendance|
      attendance.next_day = if attendance.finished_at.present? &&
                               attendance.finished_at.to_date >
                               attendance.worked_on
                              '1'
                            else
                              '0'
                            end
    end
  end

  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        next if attendance.worked_on > Date.current

        if item[:started_at].present?
          t = Time.zone.parse(item[:started_at])
          item[:started_at] = attendance.worked_on.to_time.in_time_zone.change(
            hour: t.hour, min: t.min, sec: 0
          )
        end
        if item[:finished_at].present?
          t = Time.zone.parse(item[:finished_at])
          next_day = item.delete(:next_day) == '1'
          base_date = next_day ? attendance.worked_on + 1 : attendance.worked_on
          item[:finished_at] =
            base_date.to_time.in_time_zone.change(hour: t.hour, min: t.min,
                                                  sec: 0)
        else
          item.delete(:next_day)
        end
        attendance.assign_attributes(item)
        attendance.check_in_only_invalid = true
        attendance.save!
      end
    end
    flash[:success] = if params[:mode] == 'week'
                        '1週間分の勤怠情報を更新しました。'
                      else
                        '1ヶ月分の勤怠情報を更新しました。'
                      end
    redirect_to user_url(date: params[:date], mode: params[:mode])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
    redirect_to attendances_edit_one_month_user_url(date: params[:date],
                                                    mode: params[:mode])
  end
  

  private

  def attendances_params
    params.require(:user).permit(attendances: %i[started_at finished_at
                                                 note next_day])[:attendances]
  end

  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
  end
end
