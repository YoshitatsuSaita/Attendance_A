# 所属長承認申請を管理するモデル
class ApprovalRequest < ApplicationRecord
  belongs_to :user
  belongs_to :superior, class_name: 'User'

  enum :status, { none: 0, pending: 1, approved: 2, rejected: 3 }

  validates :target_month, presence: true
  validates :status, presence: true
end
