# 拠点情報を管理するモデル
class Base < ApplicationRecord
  enum :attendance_type, { standard: 0, flex: 1, shift: 2 }

  validates :base_number, presence: true
  validates :name, presence: true
  validates :attendance_type, presence: true
end
