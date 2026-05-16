class Attendance < ApplicationRecord
  belongs_to :user
  attr_accessor :next_day


  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  # 現在の日付より先の日付の情報を編集しようとした場合、無効
  validate :future_edit_invalid , on: :update

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at && started_at.to_date == finished_at.to_date
    end
  end

  def future_edit_invalid
    errors.add(:worked_on, "が未来の勤怠情報は無効です") if worked_on > Date.current
  end
end
