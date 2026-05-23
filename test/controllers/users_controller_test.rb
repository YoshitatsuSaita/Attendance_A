require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get signup_url
    assert_response :success
  end

  test '一般ユーザーは index にアクセスできない' do
    post login_url,
         params: { session: { email: 'archer@example.com',
                              password: 'password' } }
    get users_url
    assert_redirected_to root_url
  end

  test '一般ユーザーは他ユーザーのshow にアクセスできない' do
    post login_url,
         params: { session: { email: 'archer@example.com',
                              password: 'password' } }
    get user_url(users(:michael))
    assert_redirected_to root_url
  end

  test '名前で検索すると一致するユーザーが表示される' do
    post login_url, params: { session: { email: 'michael@example.com', password:
  'password' } }
    get users_url, params: { q: 'mic' }
    assert_match 'michael', response.body
  end

  test '不一致のユーザーは表示されない' do
    post login_url, params: { session: { email: 'michael@example.com', password:
  'password' } }
    get users_url, params: { q: 'zzz' }
    assert_no_match 'michael', response.body
  end

  test '週表示モードでユーザーの勤怠ページを表示できる' do
    post login_url, params: { session: { email: 'archer@example.com', password:
    'password' } }
    get user_url(users(:archer), mode: 'week')
    assert_response :success
    assert_match '◀', response.body
  end
end
