require 'rails_helper'

RSpec.describe 'AttendanceCorrectionLogs', type: :request do
  let(:user) { create(:user) }
  let(:approver) { create(:user, superior: true) }

  describe 'GET index' do
    before do
      post login_path,
           params: { session: { email: user.email, password: user.password } }
    end

    context '自分の承認済み修正ログがある場合' do
      before do
        create(:attendance_correction_log, user: user, approver: approver,
                                           worked_on: Date.new(2026, 2, 1))
        get attendance_correction_logs_path
      end

      it '200 HTTPレスポンスを返す' do
        expect(response).to have_http_status(:ok)
      end

      it '承認者名が表示される' do
        expect(response.body).to include(approver.name)
      end
    end

    context '年・月で絞り込んだ場合' do
      before do
        create(:attendance_correction_log, user: user, approver: approver,
                                           worked_on: Date.new(2026, 2, 1))
        create(:attendance_correction_log, user: user, approver: approver,
                                           worked_on: Date.new(2026, 3, 1))
        get attendance_correction_logs_path, params: { year: 2026, month: 2 }
      end

      it '指定した月の日付のみ表示する' do
        expect(response.body).to include('2026/02/01')
        expect(response.body).not_to include('2026/03/01')
      end
    end
  end

  describe 'GET index（未ログイン）' do
    before { get attendance_correction_logs_path }

    it 'ログインページへリダイレクトする' do
      expect(response).to redirect_to(login_url)
    end
  end
end
