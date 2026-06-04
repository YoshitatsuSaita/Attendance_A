# 拠点情報を管理するモデル
class WorkBase < ApplicationRecord
  enum :attendance_type, { clock_in: 0, clock_out: 1 }

  validates :base_number, presence: true
  validates :name, presence: true
  validates :attendance_type, presence: true
end
