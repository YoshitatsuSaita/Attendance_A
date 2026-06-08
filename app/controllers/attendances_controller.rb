# 勤怠情報の登録・編集を管理するコントローラー
class AttendancesController < ApplicationController
  before_action :set_user, only: :edit_one_month
  before_action :logged_in_user, only: %i[update edit_one_month]
  before_action :not_admin, only: %i[update edit_one_month]
  before_action :correct_user_only, only: %i[update edit_one_month]
  before_action :set_attendance_period, only: :edit_one_month
  before_action :set_superiors, only: :edit_one_month

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

  private

  # 申請先（指示者）候補は上長ユーザー。上長本人の編集では自身を除外する。
  def set_superiors
    @superiors = User.superiors.where.not(id: current_user.id)
  end

  # 管理者は not_admin で除外済み。ここでは本人のみ許可します。
  def correct_user_only
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user?(@user)

    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
  end
end
