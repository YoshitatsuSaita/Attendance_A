# 所属長承認申請の作成・承認を管理するコントローラー
class ApprovalRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :not_admin
  before_action :superior_user, only: %i[received review]

  # 上長宛ての申請中・否認済みの所属長承認申請（お知らせ）を申請者ごとに表示する
  def received
    @approval_requests_by_user = current_user.received_approval_requests
                                             .where(status: %i[pending rejected])
                                             .includes(:user)
                                             .order(:target_month)
                                             .group_by(&:user)
    render partial: 'approval_requests/received'
  end

  # 変更チェックの付いた行のみ指示者確認欄（status）を反映する
  def review
    apply_review(current_user.received_approval_requests,
                 review_params, '所属長承認申請')
    redirect_to user_url(current_user, date: params[:date], mode: params[:mode])
  end

  def create
    @approval_request =
      current_user.approval_requests.build(approval_request_params)
    @approval_request.status = :pending
    ActiveRecord::Base.transaction do
      current_user.approval_requests
                  .where(target_month: @approval_request.target_month)
                  .where(status: %i[pending rejected])
                  .destroy_all
      @approval_request.save!
    end
    flash[:success] = '所属長承認申請を送信しました。'
    redirect_to user_url(current_user, date: params[:date],
                                       mode: params[:mode])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = @approval_request.errors.full_messages.join('<br>')
    redirect_to user_url(current_user, date: params[:date],
                                       mode: params[:mode])
  end

  private

  def approval_request_params
    params.require(:approval_request).permit(:target_month, :superior_id)
  end

  def review_params
    params.permit(approval_requests: %i[status apply])
          .fetch(:approval_requests, {})
  end
end
