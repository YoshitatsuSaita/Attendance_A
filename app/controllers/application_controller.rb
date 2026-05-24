# アプリケーション全体の共通処理を提供するベースコントローラー
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  # beforeフィルター

  # paramsからユーザー取得
  def set_user
    @user = User.find(params[:id])
  end

  # ログイン済みのユーザーか確認します。
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'ログインしてください。'
    redirect_to login_url
  end

  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    return if current_user?(@user)

    flash[:danger] = '権限がありません。'
    redirect_to(root_url)
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    return if current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  # 本人またはシステム管理権限所有かどうか判定します。
  def correct_or_admin_user
    return if current_user.admin? || current_user?(@user)

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  # 管理ユーザーのみアクセス可（管理者専用ページ用）
  def admin_user_only
    return if current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  # 上長または管理ユーザーのみアクセス可
  def superior_or_admin
    return if current_user.superior? || current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  # 管理ユーザー以外（一般・上長）のみアクセス可
  def not_admin
    return unless current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    @first_day = if params[:date].nil?
                   Date.current.beginning_of_month
                 else
                   params[:date].to_date
                 end
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances
                        .where(worked_on: @first_day..@last_day)
                        .order(:worked_on)

    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances
                          .where(worked_on: @first_day..@last_day)
                          .order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = 'ページ情報の取得に失敗しました、再アクセスしてください。'
    redirect_to root_url
  end

  # 1週間分のデータの存在を確認・セットします。
  def set_one_week
    @first_day = if params[:date].nil?
                   Date.current.beginning_of_week
                 else
                   params[:date].to_date
                 end
    @last_day = @first_day + 6
    one_week = [*@first_day..@last_day]
    # ユーザーに紐付く1週間分のレコードを検索し取得します。
    @attendances = @user.attendances
                        .where(worked_on: @first_day..@last_day)
                        .order(:worked_on)

    unless one_week.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1週間分の勤怠データを生成します。
        one_week.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances
                          .where(worked_on: @first_day..@last_day)
                          .order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = 'ページ情報の取得に失敗しました、再アクセスしてください。'
    redirect_to root_url
  end

  def set_attendance_period
    if params[:mode] == 'week'
      set_one_week
    else
      set_one_month # デフォルトは月表示
    end
  end
end
