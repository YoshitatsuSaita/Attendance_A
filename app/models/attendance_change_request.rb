# 勤怠変更申請を管理するモデル
class AttendanceChangeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :superior, class_name: 'User'

  # フォームの時刻入力（HH:MM）と翌日チェックを受け取り after_* を組み立てる
  attr_accessor :started_time, :finished_time, :next_day

  enum :status, { none: 0, pending: 1, approved: 2, rejected: 3 },
       prefix: true

  validates :worked_on, presence: true
  validates :status, presence: true
  validate :require_both_times
  validate :finished_after_started

  before_validation :assemble_after_times
  after_update :apply_approval,
               if: -> { saved_change_to_status? && status_approved? }

  private

  # 承認時の反映処理。勤怠（実績）を更新し、修正ログを残す。
  def apply_approval
    reflect_to_attendance
    record_correction_log
  end

  # 承認時、申請者の該当日の勤怠（実績）へ変更後の時刻・備考を反映する
  def reflect_to_attendance
    attendance = user.attendances.find_by(worked_on: worked_on)
    return unless attendance

    attendance.update!(started_at: after_started_at,
                       finished_at: after_finished_at,
                       note: note)
  end

  # 承認時、変更前後の時刻と承認者（上長）を修正ログとして記録する
  def record_correction_log
    AttendanceCorrectionLog.create!(
      user_id: user_id,
      worked_on: worked_on,
      before_started_at: before_started_at,
      before_finished_at: before_finished_at,
      after_started_at: after_started_at,
      after_finished_at: after_finished_at,
      approver_id: superior_id
    )
  end

  # 入力時刻を worked_on（退社が翌日なら翌日）の時刻に変換する。
  # 申請後の更新（承認など）では時刻入力が無いため、既存値を保持する。
  def assemble_after_times
    if started_time.present?
      self.after_started_at = build_time(started_time, worked_on)
    end
    return if finished_time.blank?

    self.after_finished_at = build_time(finished_time, finished_base_date)
  end

  # HH:MM 文字列を指定日の datetime に変換する（空欄なら nil）
  def build_time(time_str, base_date)
    return if time_str.blank? || base_date.blank?

    time = Time.zone.parse(time_str)
    base_date.to_time.in_time_zone
             .change(hour: time.hour, min: time.min, sec: 0)
  end

  # 退社時間の基準日。翌日チェック時は worked_on の翌日を返す
  def finished_base_date
    return if worked_on.blank?
    return worked_on unless ActiveModel::Type::Boolean.new.cast(next_day)

    worked_on + 1
  end

  # 出社・退社どちらか一方のみは不可
  def require_both_times
    return if after_started_at.present? && after_finished_at.present?

    errors.add(:base, '出社時間と退社時間は両方入力してください')
  end

  # 退社時間は出社時間より後であること
  def finished_after_started
    return unless after_started_at.present? && after_finished_at.present?
    return if after_finished_at > after_started_at

    errors.add(:after_finished_at, 'は出社時間より後の時間を指定してください')
  end
end
