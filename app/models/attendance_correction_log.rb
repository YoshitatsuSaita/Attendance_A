# 承認済み勤怠修正ログを管理するモデル
class AttendanceCorrectionLog < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: 'User'

  validates :worked_on, presence: true
end
