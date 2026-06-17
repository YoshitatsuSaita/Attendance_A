# ユーザー情報表示に関するヘルパーメソッド
module UsersHelper
  # 勤怠基本情報を指定のフォーマットで返します。
  def format_basic_info(time)
    format('%.2f', ((time.hour * 60) + time.min) / 60.0)
  end

  # お知らせリンクの色クラスを返す。申請中または否認が1件以上あれば赤字にする。
  def notice_link_class(pending_count, rejected_count)
    base = 'notice-links__link'
    return base unless pending_count.to_i.positive? || rejected_count.to_i.positive?

    "#{base} notice-links__link--alert"
  end

  # お知らせリンクのラベルを「申請中〇件 否認〇件」形式で組み立てる
  def notice_label(title, pending_count, rejected_count)
    parts = []
    parts << "申請中#{pending_count}件" if pending_count.to_i.positive?
    parts << "否認#{rejected_count}件" if rejected_count.to_i.positive?
    suffix = parts.any? ? " #{parts.join(' ')}" : ''
    "【#{title}のお知らせ#{suffix}】"
  end
end
