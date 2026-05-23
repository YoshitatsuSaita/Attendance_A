# アプリケーション全体で使用する共通ヘルパーメソッド
module ApplicationHelper
  DAYS_OF_THE_WEEK = %w[日 月 火 水 木 金 土].freeze

  # 曜日名を返す（日=0, 月=1, ..., 土=6）
  def days_of_the_week
    DAYS_OF_THE_WEEK
  end

  # ページごとにタイトルを返す
  def full_title(page_name = '')
    base_title = '勤怠A'
    if page_name.empty?
      base_title
    else
      "#{page_name} | #{base_title}"
    end
  end
end
