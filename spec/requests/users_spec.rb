require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET index' do
    let(:user) { create(:user) }
    # index は管理者のみ・自己除外のため、一覧に含めない別管理者でログインする
    let(:admin) { create(:user, admin: true) }

    context 'ユーザーが5件存在する場合' do
      let(:users) { create_list(:user, 4) + [user] }

      before do
        # 他テスト(Minitest)のフィクスチャがコミット残存し件数がぶれるため、
        # 一旦クリアしてからテストデータを作成して件数を確定させる
        Attendance.delete_all
        User.delete_all
        users
        post login_path,
             params: { session: { email: admin.email,
                                  password: admin.password } }
        get users_path, as: :json
      end

      it '200 httpレスポンスを返す' do
        expect(response.status).to eq 200
      end

      it 'ユーザーが5件を返す' do
        json_response = response.parsed_body
        expect(json_response.length).to eq(5)
      end

      it '5件のユーザーを正確に返す' do
        json_response = response.parsed_body
        expected_users = users.map do |user|
          {
            'id' => user.id,
            'name' => user.name,
            'email' => user.email,
            'created_at' => user.created_at.as_json,
            'updated_at' => user.updated_at.as_json,
            'department' => user.department,
            'basic_time' => user.basic_time.as_json,
            'work_time' => user.work_time.as_json
          }
        end
        expect(json_response).to match_array(expected_users)
      end

      # ページネーションに関するテスト
      context 'ページネーションを含む場合' do
        let(:users) { create_list(:user, 34) + [user] }

        it '1ページ目に30件のユーザを返す' do
          get users_path, params: { page: 1 }, as: :json
          json_response = response.parsed_body
          expect(json_response.length).to eq(30)
        end

        it '2ページ目に5件のユーザーを返す' do
          get users_path, params: { page: 2 }, as: :json
          json_response = response.parsed_body
          expect(json_response.length).to eq(5)
        end
      end
    end
  end

  describe 'GET show' do
    let(:user) { create(:user) }

    before do
      post login_path,
           params: { session: { email: user.email,
                                password: user.password } }
      get user_path(user), as: :json
    end

    context '1件のユーザーが存在する場合' do
      it '200 HTTPレスポンスを返す' do
        expect(response.status).to eq 200
      end

      it '指定されたユーザーを返す' do
        json_response = response.parsed_body
        expected_data = {
          'id' => user.id,
          'name' => user.name,
          'email' => user.email,
          'created_at' => user.created_at.as_json,
          'updated_at' => user.updated_at.as_json,
          'department' => user.department,
          'basic_time' => user.basic_time.as_json,
          'work_time' => user.work_time.as_json
        }
        expect(json_response).to eq(expected_data)
      end
    end
  end

  describe 'GET new' do
    before do
      get new_user_path, as: :json
    end

    it '200 HTTPレスポンスを返す' do
      expect(response.status).to eq 200
    end

    it '新しいユーザーインスタンスが生成される' do
      json_response = response.parsed_body
      # basic_time/work_time はデータベースのデフォルト値
      expected_data = {
        'basic_time' => '2026-05-23T08:00:00.000+09:00',
        'work_time' => '2026-05-23T07:30:00.000+09:00',
        'created_at' => nil,
        'department' => nil,
        'email' => nil,
        'id' => nil,
        'name' => nil,
        'updated_at' => nil
      }
      expect(json_response).to eq(expected_data)
    end
  end

  describe 'POST create' do
    context '有効な値の場合' do
      let(:user_params) do
        { name: 'Test User', email: 'test@example.com', password: 'password',
          password_confirmation: 'password' }
      end
      let(:json_response) { response.parsed_body }

      before do
        post users_path, params: { user: user_params }, as: :json
      end

      it '201 Created ステータスコードを返す' do
        expect(response).to have_http_status(:created)
      end

      it 'ユーザーが生成される' do
        # basic_time/work_time はデータベースのデフォルト値
        expect(json_response).to include({
                                           'basic_time' =>
                                             '2026-05-23T08:00:00.000+09:00',
                                           'work_time' =>
                                             '2026-05-23T07:30:00.000+09:00',
                                           'department' => nil,
                                           'email' => 'test@example.com',
                                           'name' => 'Test User'
                                         })
        expect(json_response).to include('id', 'created_at', 'updated_at')
      end

      it 'ユーザーがデータベースに保存される' do
        expect(User.last).to have_attributes(name: 'Test User',
                                             email: 'test@example.com')
      end
    end

    context '無効な値の場合' do
      before do
        post users_path,
             params: {
               user: {
                 name: '',
                 email: 'user@example.com',
                 password: 'password',
                 password_confirmation: 'password'
               }
             }, as: :json
      end

      it '422 Unprocessable Entity ステータスコードを返す' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'ユーザーが作成されない' do
        expect do
          post users_path,
               params: {
                 user: {
                   name: '',
                   email: 'user@example.com',
                   password: 'password',
                   password_confirmation: 'password'
                 }
               }, as: :json
        end.not_to(change(User, :count))
      end

      it 'エラーレスポンスが含まれている' do
        json_response = response.parsed_body
        expect(json_response).to be_present
      end

      it 'バリデーションメッセージで「名前を入力してください」を返す' do
        json_response = response.parsed_body
        expect(json_response['name']).to eq(['を入力してください'])
      end
    end
  end

  describe 'PATCH update' do
    let(:user) do
      create(:user, name: 'Existing User', email: 'existing@example.com',
                    password: 'password', password_confirmation: 'password')
    end
    let(:json_response) { response.parsed_body }

    context '有効な値の場合' do
      let(:user_params) do
        { name: 'Updated User', email: 'updated@example.com' }
      end

      before do
        post login_path,
             params: { session: { email: user.email,
                                  password: user.password } }
        patch user_path(user), params: { user: user_params }, as: :json
      end

      it '200 httpレスポンスを返す' do
        expect(response.status).to eq 200
      end

      it 'ユーザー情報が更新される' do
        expect(json_response).to include({
                                           'name' => 'Updated User',
                                           'email' => 'updated@example.com'
                                         })
        expect(json_response).to include('id', 'created_at', 'updated_at')
      end

      it 'ユーザーのデータベースで更新される' do
        user.reload
        expect(user).to have_attributes(name: 'Updated User',
                                        email: 'updated@example.com')
      end
    end

    context '無効な値の場合' do
      before do
        post login_path,
             params: { session: { email: user.email,
                                  password: user.password } }
        patch user_path(user),
              params: {
                user: { name: '', email: 'invalid@example.com' }
              }, as: :json
      end

      it '422 Unprocessable Entity ステータスコードを返す' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'ユーザー情報が更新されない' do
        user.reload
        expect(user).to have_attributes(name: 'Existing User',
                                        email: 'existing@example.com')
      end

      it 'エラーレスポンスが含まれている' do
        expect(json_response).to be_present
      end

      it 'バリデーションメッセージで「名前を入力してください」を返す' do
        expect(json_response['name']).to eq(['を入力してください'])
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:admin_user) { create(:user, admin: true) }
    let(:target_user) { create(:user) }

    before do
      admin_user
      target_user
      post login_path,
           params: { session: { email: admin_user.email,
                                password: admin_user.password } }
    end

    it 'ユーザーがデータベースから削除される' do
      expect do
        delete user_path(target_user)
      end.to change(User, :count).by(-1)
    end

    it '302 Found ステータスコードを返す' do
      delete user_path(target_user)
      expect(response).to have_http_status(:found)
    end

    it 'フラッシュメッセージで「「ユーザー名」のデータを削除しました」と返す' do
      delete user_path(target_user)
      expect(flash[:success]).to eq("#{target_user.name}のデータを削除しました。")
    end

    it 'ユーザー一覧ページにリダイレクトされる' do
      delete user_path(target_user)
      expect(response).to redirect_to(users_url)
    end
  end
end
