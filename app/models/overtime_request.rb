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
