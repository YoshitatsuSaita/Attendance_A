# ユーザーの登録・編集・削除・勤怠表示を管理するコントローラー
class UsersController < ApplicationController
  before_action :set_user,
                only: %i[show edit update destroy update_basic_info]
  before_action :logged_in_user,
                only: %i[index show edit update destroy
                         update_basic_info
                         edit_all_basic_info update_all_basic_info
                         import working]
  before_action :correct_user, only: %i[edit update]
  before_action :correct_or_superior_user, only: :show
  before_action :admin_user,
                only: %i[index destroy update_basic_info
                         edit_all_basic_info update_all_basic_info
                         import working]
  before_action :not_admin, only: :show
  before_action :set_attendance_period, only: :show
  before_action :prevent_self_destroy, only: :destroy
  before_action :prevent_last_admin_destroy, only: :destroy

  def index
    @users = User.where.not(id: current_user.id)
    if params[:q].present?
      q = ActiveRecord::Base.sanitize_sql_like(params[:q])
      @users = @users.where('name LIKE ?', "%#{q}%")
    end
    @users = @users.order(superior: :desc, id: :asc)
                   .paginate(page: params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overtime_requests = @user.overtime_requests
                              .where(worked_on: @first_day..@last_day)
                              .includes(:superior)
                              .order(:created_at)
                              .index_by(&:worked_on)
    @attendance_change_requests = @user.attendance_change_requests
                                       .where(worked_on: @first_day..@last_day)
                                       .includes(:superior)
                                       .order(:created_at)
                                       .index_by(&:worked_on)
    @approval_request = @user.approval_requests
                             .where(target_month: @first_day)
                             .includes(:superior)
                             .order(:created_at)
                             .last
    set_pending_request_counts
    respond_to do |format|
      format.html
      format.json { render json: @user }
      format.csv do
        send_data @attendances.to_csv,
                  filename: attendance_csv_filename, type: 'text/csv'
      end
    end
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def edit; end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        log_in @user
        flash[:success] = '新規作成に成功しました。'
        format.html { redirect_to @user }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render :new }
        format.json do
          render json: @user.errors, status: :unprocessable_content
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        flash[:success] = 'ユーザー情報を更新しました。'
        format.html { redirect_to @user }
        format.json { render json: @user, status: :ok }
      else
        format.html { render :edit }
        format.json do
          render json: @user.errors, status: :unprocessable_content
        end
      end
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def update_basic_info
    if @user.update(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] =
        "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join('<br>')
    end

    respond_to do |format|
      format.html { redirect_to users_url }
      format.turbo_stream { redirect_to users_url }
    end
  end

  def edit_all_basic_info
    @user = User.new
  end

  def working
    dates = [Date.current.yesterday, Date.current]
    @users = User.joins(:attendances)
                 .where(attendances: { worked_on: dates })
                 .where.not(attendances: { started_at: nil })
                 .where(attendances: { finished_at: nil })
                 .distinct
                 .order(:employee_number)
  end

  def import
    if params[:file].blank?
      flash[:danger] = 'CSVファイルを選択してください。'
    else
      User.import(params[:file])
      flash[:success] = 'CSVをインポートしました。'
    end
    redirect_to users_url
  rescue ActiveRecord::RecordInvalid => e
    flash[:danger] = "インポートに失敗しました: #{e.message}"
    redirect_to users_url
  end

  def update_all_basic_info
    success = true
    User.find_each do |user|
      success = false unless user.update(basic_info_params)
    end

    if success
      flash[:success] = '基本情報を更新しました。'
      redirect_to users_url
    else
      flash.now[:danger] = '基本情報の編集に失敗しました。'
      render :edit_all_basic_info,
             status: :unprocessable_content
    end
  end

  private

  # 表示中の勤怠 CSV のファイル名を組み立てる
  def attendance_csv_filename
    "勤怠_#{@user.name}_#{@first_day.strftime('%Y-%m')}.csv"
  end

  # 上長が受け取った未処理（申請中）の各種申請件数をセットする
  def set_pending_request_counts
    return unless current_user.superior?

    @pending_overtime_count =
      current_user.received_overtime_requests.status_pending.count
    @pending_change_count =
      current_user.received_attendance_change_requests.status_pending.count
    @pending_approval_count =
      current_user.received_approval_requests.status_pending.count
  end

  def user_params
    params.require(:user).permit(:name, :email, :department, :password,
                                 :password_confirmation)
  end

  def basic_info_params
    params.require(:user).permit(
      :name, :email, :department, :employee_number, :uid,
      :password, :password_confirmation,
      :basic_time, :work_time,
      :designated_work_start_time, :designated_work_end_time
    )
  end

  def prevent_self_destroy
    return unless current_user?(@user)

    flash[:danger] = '自分自身を削除することはできません。'
    redirect_to users_url
  end

  def prevent_last_admin_destroy
    return unless @user.admin? && User.where(admin: true).count <= 1

    flash[:danger] = '最後の管理者は削除できません。'
    redirect_to users_url
  end
end
