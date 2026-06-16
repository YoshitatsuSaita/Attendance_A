require 'rails_helper'

RSpec.describe AttendanceCorrectionLog, type: :model do
  let(:user) { create(:user) }
  let(:approver) { create(:user, superior: true) }

  describe '.aggregated_history' do
    context '同一日付に複数回の修正が承認されている場合' do
      before do
        create_log(10, 18, 11, 19, created_at: 3.days.ago)
        create_log(11, 19, 12, 20, created_at: 2.days.ago)
        create_log(12, 20, 13, 21, created_at: 1.day.ago)
      end

      it '変更前は最初・変更後は最後の修正時刻に集約される' do
        history = user.attendance_correction_logs.aggregated_history.first
        times = [history.before_started_at, history.before_finished_at,
                 history.after_started_at, history.after_finished_at]
        expect(times.map { |t| t.strftime('%H:%M') })
          .to eq(%w[10:00 18:00 13:00 21:00])
      end

      it '承認日は最後に承認された日時になる' do
        history = user.attendance_correction_logs.aggregated_history.first
        latest = user.attendance_correction_logs.order(:created_at).last
        expect(history.approved_at).to eq(latest.created_at)
      end
    end

    context '修正された日付が複数ある場合' do
      before do
        create(:attendance_correction_log, user: user, approver: approver,
                                           worked_on: Date.new(2026, 2, 1))
        create(:attendance_correction_log, user: user, approver: approver,
                                           worked_on: Date.new(2026, 2, 2))
      end

      it '対象日ごとに1件ずつ集約して返す' do
        histories = user.attendance_correction_logs.aggregated_history
        expect(histories.map(&:worked_on))
          .to eq([Date.new(2026, 2, 1), Date.new(2026, 2, 2)])
      end
    end
  end

  describe '.recorded_years' do
    before do
      create(:attendance_correction_log, user: user, approver: approver,
                                         worked_on: Date.new(2024, 5, 1))
      create(:attendance_correction_log, user: user, approver: approver,
                                         worked_on: Date.new(2026, 2, 1))
    end

    it 'ログが存在する年を重複なく新しい順で返す' do
      expect(user.attendance_correction_logs.recorded_years).to eq([2026, 2024])
    end
  end

  describe '.in_year, .in_month' do
    before do
      create(:attendance_correction_log, user: user, approver: approver,
                                         worked_on: Date.new(2026, 2, 1))
      create(:attendance_correction_log, user: user, approver: approver,
                                         worked_on: Date.new(2026, 3, 1))
    end

    it '指定した年・月の修正ログのみ抽出する' do
      logs = user.attendance_correction_logs.in_year(2026).in_month(2)
      expect(logs.pluck(:worked_on)).to eq([Date.new(2026, 2, 1)])
    end
  end

  def create_log(before_h, before_f, after_h, after_f, created_at:)
    create(:attendance_correction_log, user: user, approver: approver,
                                       worked_on: Date.new(2026, 2, 1),
                                       before_started_at: time_at(before_h),
                                       before_finished_at: time_at(before_f),
                                       after_started_at: time_at(after_h),
                                       after_finished_at: time_at(after_f),
                                       created_at: created_at)
  end

  def time_at(hour)
    Time.zone.local(2026, 2, 1, hour)
  end
end
