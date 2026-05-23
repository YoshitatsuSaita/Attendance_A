require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    described_class.new(name: 'Valid Name', email: 'test@user.com',
                        password: 'password')
  end

  describe 'バリデーション' do
    context '名前が設定されていて、かつ50文字以下の場合' do
      it 'バリデーションが通る' do
        expect(user.valid?).to be(true)
      end
    end

    context '名前が設定されていない場合' do
      it 'バリデーションが通らない' do
        user.name = nil
        expect(user.valid?).to be(false)
      end
    end

    context '名前が51文字以上の場合' do
      it 'バリデーションが通らない' do
        user.name = 'a' * 51
        expect(user.valid?).to be(false)
      end
    end

    context 'メールアドレスが正しく設定されている場合' do
      it 'バリデーションが通る' do
        expect(user.valid?).to be(true)
      end
    end

    context 'メールアドレスが空の場合' do
      it 'バリデーションが通らない' do
        user.email = nil
        expect(user.valid?).to be(false)
      end
    end

    context 'メールアドレスが100文字以下の場合' do
      it 'バリデーションが通る' do
        user.email = "#{'a' * 7}@example.com"
        expect(user.valid?).to be(true)
      end
    end

    context 'メールアドレスが100文字を超える場合' do
      it 'バリデーションが通らない' do
        user.email = "#{'a' * 101}@example.com"
        expect(user.valid?).to be(false)
      end
    end

    context 'メールアドレスのフォーマットが不適切な場合' do
      it 'バリデーションが通らない' do
        user.email = 'invalid_email'
        expect(user.valid?).to be(false)
      end
    end

    context '同じメールアドレスを持つユーザーが既に存在する場合' do
      before do
        described_class.create!(
          name: 'Existing User',
          email: 'duplicate@example.com',
          password: 'password'
        )
      end

      it 'バリデーションが通らない' do
        user.email = 'duplicate@example.com'
        expect(user.valid?).to be(false)
      end
    end

    context 'パスワードが設定されている場合' do
      it 'バリデーションが通る' do
        expect(user.valid?).to be(true)
      end
    end

    context 'パスワードが設定されていない場合' do
      it 'バリデーションが通らない' do
        user.password = nil
        expect(user.valid?).to be(false)
      end
    end

    context 'パスワードが6文字未満の場合' do
      it 'バリデーションが通らない' do
        user.password = '12345'
        expect(user.valid?).to be(false)
      end
    end

    context 'パスワードが6文字以上の場合' do
      it 'バリデーションが通る' do
        user.password = '123456'
        expect(user.valid?).to be(true)
      end
    end
  end

  describe '#as_json' do
    it '許可されたキーのみ含む' do
      json = user.as_json
      expect(json.keys).to match_array(%w[id name email department basic_time
                                          work_time created_at updated_at])
    end

    it 'password_digest を含まない' do
      expect(user.as_json).not_to have_key('password_digest')
    end

    it 'remember_digest を含まない' do
      expect(user.as_json).not_to have_key('remember_digest')
    end

    it 'admin を含まない' do
      expect(user.as_json).not_to have_key('admin')
    end
  end
end
