# 残業申請の作成を管理するコントローラー
class OvertimeRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :not_admin
  before_action :superior_user, only: %i[received review]
  before_action :set_superiors, only: %i[new create]

  def new
    @overtime_request =
      current_user.overtime_requests.build(worked_on: params[:worked_on])
    render partial: 'overtime_requests/form'
  end

  # 上長宛ての申請中・否認済みの残業申請（お知らせ）を申請者ごとに表示する
  def received
    @overtime_requests_by_user = current_user.received_overtime_requests
                                             .where(status: %i[pending rejected])
                                             .includes(:user)
                                             .order(:worked_on)
                                             .group_by(&:user)
    render partial: 'overtime_requests/received'
  end

  # 変更チェックの付いた行のみ指示者確認欄（status）を反映する
  def review
    apply_review(current_user.received_overtime_requests,
                 review_params, '残業申請')
    redirect_to user_url(current_user, date: params[:date], mode: params[:mode])
  end

  def create
    @overtime_request =
      current_user.overtime_requests.build(overtime_request_params)
    @overtime_request.status = :pending
    ActiveRecord::Base.transaction do
      current_user.overtime_requests
                  .where(worked_on: @overtime_request.worked_on)
                  .where(status: %i[pending rejected])
                  .destroy_all
      @overtime_request.save!
    end
    flash[:success] = '残業申請を送信しました。'
    redirect_to user_url(current_user, date: params[:date],
                                       mode: params[:mode])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = @overtime_request.errors.full_messages.join('<br>')
    redirect_to user_url(current_user, date: params[:date],
                                       mode: params[:mode])
  end

  private

  def overtime_request_params
    params.require(:overtime_request)
          .permit(:worked_on, :end_time, :next_day, :work_content,
                  :superior_id)
  end

  def review_params
    params.permit(overtime_requests: %i[status apply])
          .fetch(:overtime_requests, {})
  end

  # 申請先（指示者）候補は上長ユーザー。上長本人の申請では自身を除外する。
  def set_superiors
    @superiors = User.superiors.where.not(id: current_user.id)
  end
end
