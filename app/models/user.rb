require 'csv'

# ユーザー情報・認証・記憶トークンを管理するモデル
class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :overtime_requests, dependent: :destroy
  has_many :received_overtime_requests,
           class_name: 'OvertimeRequest',
           foreign_key: :superior_id,
           dependent: :destroy,
           inverse_of: :superior
  has_many :attendance_change_requests, dependent: :destroy
  has_many :received_attendance_change_requests,
           class_name: 'AttendanceChangeRequest',
           foreign_key: :superior_id,
           dependent: :destroy,
           inverse_of: :superior
  has_many :approval_requests, dependent: :destroy
  has_many :received_approval_requests,
           class_name: 'ApprovalRequest',
           foreign_key: :superior_id,
           dependent: :destroy,
           inverse_of: :superior
  has_many :attendance_correction_logs, dependent: :destroy

  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..30 }, allow_blank: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validate :password_required_with_confirmation

  scope :superiors, -> { where(superior: true) }
  scope :admins, -> { where(admin: true) }

  before_save { self.email = email.downcase }

  # CSVヘッダーと取り込む属性の対応を定義します。
  CSV_ATTRIBUTES = %w[
    name email department employee_number uid
    designated_work_start_time designated_work_end_time
    password superior admin
  ].freeze

  # CSVファイルを読み込み、emailをキーにユーザーを登録・更新します。
  def self.import(file)
    transaction do
      CSV.foreach(file.path, headers: true) do |row|
        user = find_or_initialize_by(email: row['email'])
        user.assign_attributes(
          name: row['name'],
          department: row['department'],
          employee_number: row['employee_number'],
          uid: row['uid'],
          designated_work_start_time: row['designated_work_start_time'],
          designated_work_end_time: row['designated_work_end_time'],
          superior: to_boolean(row['superior']),
          admin: to_boolean(row['admin'])
        )
        user.password = row['password'] if row['password'].present?
        user.save!
      end
    end
  end

  # 文字列の真偽値を boolean に変換します（空欄は false 扱い）。
  def self.to_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value) || false
  end

  # 渡された文字列のハッシュ値を返します。
  def self.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end

  def admin?
    admin
  end

  def superior?
    superior
  end

  def as_json(options = {})
    super({ only: %i[id name email department basic_time work_time
                     created_at updated_at] }.merge(options))
  end

  private

  # 再入力欄のみ入力された場合（password 本体が空）は変更失敗とする。
  # has_secure_password の確認検証は password が空だと allow_blank で
  # スキップされるため、ここで明示的に弾く。
  def password_required_with_confirmation
    return if password_confirmation.blank?
    return if password.present?

    errors.add(:password, :blank)
  end
end
