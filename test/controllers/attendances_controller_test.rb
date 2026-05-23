require 'test_helper'

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test '一般ユーザーは他ユーザーの勤怠月編集にアクセスできない' do
    post login_url,
         params: { session: { email: 'archer@example.com',
                              password: 'password' } }
    get attendances_edit_one_month_user_url(users(:michael))
    assert_redirected_to root_url
  end

  test '管理者は他ユーザーの出退勤を更新できる' do
    post login_url,
         params: { session: { email: 'michael@example.com',
                              password: 'password' } }
    patch user_attendance_url(users(:archer), attendances(:archer_attendance))
    assert_redirected_to user_url(users(:archer))
  end
end
