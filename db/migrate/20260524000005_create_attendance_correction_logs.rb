class CreateAttendanceCorrectionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_correction_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :worked_on, null: false
      t.datetime :before_started_at
      t.datetime :before_finished_at
      t.datetime :after_started_at
      t.datetime :after_finished_at
      t.bigint :approver_id, null: false

      t.timestamps
    end

    add_foreign_key :attendance_correction_logs, :users, column: :approver_id
    add_index :attendance_correction_logs, :approver_id
  end
end
