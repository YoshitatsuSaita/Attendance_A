# 承認済み勤怠修正ログを管理するモデル
class AttendanceCorrectionLog < ApplicationRecord
  # 対象日ごとに集約した1件分の履歴を表す値オブジェクト
  History = Struct.new(:worked_on, :before_started_at, :before_finished_at,
                       :after_started_at, :after_finished_at, :approver,
                       :approved_at, keyword_init: true)

  belongs_to :user
  belongs_to :approver, class_name: 'User'

  validates :worked_on, presence: true

  scope :in_year, ->(year) { where('YEAR(worked_on) = ?', year) }
  scope :in_month, ->(month) { where('MONTH(worked_on) = ?', month) }

  # 対象日ごとに履歴を集約して返す。同一日に複数回の修正がある場合、
  # 変更前は最初に申請した時刻、変更後は最後に申請した時刻を採用する。
  def self.aggregated_history
    includes(:approver)
      .order(:created_at, :id)
      .group_by(&:worked_on)
      .map { |worked_on, logs| build_history(worked_on, logs) }
      .sort_by(&:worked_on)
  end

  # ログが存在する年を新しい順で返す（絞り込みプルダウン用）
  def self.recorded_years
    pluck(:worked_on).map(&:year).uniq.sort.reverse
  end

  def self.build_history(worked_on, logs)
    first = logs.first
    History.new(
      worked_on: worked_on,
      before_started_at: first.before_started_at || first.after_started_at,
      before_finished_at: first.before_finished_at || first.after_finished_at,
      after_started_at: logs.last.after_started_at,
      after_finished_at: logs.last.after_finished_at,
      approver: logs.last.approver,
      approved_at: logs.last.created_at
    )
  end
  private_class_method :build_history
end
