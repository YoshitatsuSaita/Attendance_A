# 勤怠変更申請を管理するモデル
class AttendanceChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :superior, class_name: 'User'

  enum :status, { none: 0, pending: 1, approved: 2, rejected: 3 },
       prefix: true

  validates :worked_on, presence: true
  validates :status, presence: true
  validate :require_both_or_neither_times
  validate :after_started_at_must_be_after_before

  private

  # 出社・退社どちらか一方のみは不可
  def require_both_or_neither_times
    return if before_started_at.present? && after_started_at.present?
    return if before_started_at.blank? && after_started_at.blank?

    errors.add(:base, '変更前・変更後の出社時間は両方入力してください')
  end

  # 変更後出社時間は変更前より未来であること
  def after_started_at_must_be_after_before
    return unless before_started_at.present? && after_started_at.present?
    return if after_started_at > before_started_at

    errors.add(:after_started_at, 'は変更前出社時間より後の時間を指定してください')
  end
end
