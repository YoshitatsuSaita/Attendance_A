# 残業申請を管理するモデル
class OvertimeRequest < ApplicationRecord
  belongs_to :user
  belongs_to :superior, class_name: 'User'

  enum :status, { none: 0, pending: 1, approved: 2, rejected: 3 },
       prefix: true

  validates :worked_on, presence: true
  validates :scheduled_end_time, presence: true
  validates :status, presence: true
end
