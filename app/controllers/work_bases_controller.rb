# 拠点情報の登録・編集・削除を管理するコントローラー
class WorkBasesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user_only
  before_action :set_work_base, only: %i[edit update destroy]

  def index
    @work_bases = WorkBase.order(:base_number)
  end

  def new
    @work_base = WorkBase.new
  end

  def edit; end

  def create
    @work_base = WorkBase.new(work_base_params)
    if @work_base.save
      flash[:success] = '拠点を追加しました。'
      redirect_to work_bases_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @work_base.update(work_base_params)
      flash[:success] = '拠点情報を更新しました。'
      redirect_to work_bases_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @work_base.destroy
    flash[:success] = '拠点を削除しました。'
    redirect_to work_bases_path
  end

  private

  def set_work_base
    @work_base = WorkBase.find(params[:id])
  end

  def work_base_params
    params.require(:work_base).permit(:base_number, :name, :attendance_type)
  end
end
