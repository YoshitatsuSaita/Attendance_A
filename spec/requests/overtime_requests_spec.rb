require 'rails_helper'

RSpec.describe 'OvertimeRequests', type: :request do
  let(:superior) { create(:user, superior: true) }
  let(:applicant) { create(:user) }

  describe 'PATCH review' do
    let!(:primary_request) do
      create(:overtime_request, user: applicant, superior: superior,
                                worked_on: Date.new(2026, 2, 1))
    end
    let!(:secondary_request) do
      create(:overtime_request, user: applicant, superior: superior,
                                worked_on: Date.new(2026, 2, 2))
    end

    before do
      post login_path,
           params: { session: { email: superior.email,
                                password: superior.password } }
    end

    context '変更にチェックを1つもつけずに反映した場合' do
      before do
        patch review_overtime_requests_path, params: {
          overtime_requests: {
            primary_request.id.to_s => { status: 'approved' },
            secondary_request.id.to_s => { status: 'approved' }
          }
        }
      end

      it '更新された申請がない警告を表示する' do
        expect(flash[:warning]).to eq('更新された残業申請がありません。')
      end

      it '申請の状態は変わらない' do
        expect(primary_request.reload).to be_status_pending
      end
    end

    context '2件中1件にチェックして反映した場合' do
      before do
        patch review_overtime_requests_path, params: {
          overtime_requests: {
            primary_request.id.to_s => { status: 'approved', apply: '1' },
            secondary_request.id.to_s => { status: 'approved' }
          }
        }
      end

      it '〇件中〇件の更新メッセージを表示する' do
        expect(flash[:success]).to eq('2件中1件の残業申請を更新しました。')
      end

      it 'チェックした申請のみ承認される' do
        expect(primary_request.reload).to be_status_approved
        expect(secondary_request.reload).to be_status_pending
      end
    end
  end
end
