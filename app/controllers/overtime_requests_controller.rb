# 残業申請の作成を管理するコントローラー
class OvertimeRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :not_admin
  before_action :set_superiors, only: %i[new create]

  def new
    @overtime_request =
      current_user.overtime_requests.build(worked_on: params[:worked_on])
    render partial: 'overtime_requests/form'
  end

  def create
    @overtime_request =
      current_user.overtime_requests.build(overtime_request_params)
    @overtime_request.status = :pending
    if @overtime_request.save
      flash[:success] = '残業申請を送信しました。'
    else
      flash[:danger] = @overtime_request.errors.full_messages.join('<br>')
    end
    redirect_to user_url(current_user, date: params[:date],
                                       mode: params[:mode])
  end

  private

  def overtime_request_params
    params.require(:overtime_request)
          .permit(:worked_on, :end_time, :next_day, :work_content,
                  :superior_id)
  end

  # 申請先（指示者）候補は上長ユーザー。上長本人の申請では自身を除外する。
  def set_superiors
    @superiors = User.superiors.where.not(id: current_user.id)
  end
end
