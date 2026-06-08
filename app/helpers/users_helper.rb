# ユーザー情報表示に関するヘルパーメソッド
module UsersHelper
  # 勤怠基本情報を指定のフォーマットで返します。
  def format_basic_info(time)
    format('%.2f', ((time.hour * 60) + time.min) / 60.0)
  end

  # お知らせリンクの色クラスを返す。未処理が1件以上あれば赤字にする。
  def notice_link_class(count)
    base = 'notice-links__link'
    return base unless count.to_i.positive?

    "#{base} notice-links__link--alert"
  end
end
