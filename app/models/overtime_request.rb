# 残業申請を管理するモデル
class OvertimeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :superior, class_name: 'User'

  # フォームの時刻入力（HH:MM）を受け取り scheduled_end_time を組み立てる
  attr_accessor :end_time

  enum :status, { none: 0, pending: 1, approved: 2, rejected: 3 },
       prefix: true

  validates :worked_on, presence: true
  validates :scheduled_end_time, presence: true
  validates :status, presence: true

  before_validation :assemble_scheduled_end_time

  # 申請者の指定勤務終了時間を worked_on の日付に合わせて返す
  def designated_end_time
    return if user.designated_work_end_time.blank? || worked_on.blank?

    worked_on.to_time.in_time_zone
             .change(hour: user.designated_work_end_time.hour,
                     min: user.designated_work_end_time.min, sec: 0)
  end

  # 時間外時間（分）。終了予定時間 − 指定勤務終了時間（負値は 0 とする）
  def overtime_minutes
    return 0 if scheduled_end_time.blank? || designated_end_time.blank?

    [((scheduled_end_time - designated_end_time) / 60).to_i, 0].max
  end

  private

  # 終了予定時間を worked_on（翌日チェック時はその翌日）の時刻に変換する
  def assemble_scheduled_end_time
    return if end_time.blank? || worked_on.blank?

    time = Time.zone.parse(end_time)
    base_date = next_day ? worked_on + 1 : worked_on
    self.scheduled_end_time = base_date.to_time.in_time_zone
                                       .change(hour: time.hour,
                                               min: time.min, sec: 0)
  end
end
