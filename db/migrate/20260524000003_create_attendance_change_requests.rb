class CreateAttendanceChangeRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_change_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :superior_id, null: false
      t.date :worked_on, null: false
      t.datetime :before_started_at
      t.datetime :after_started_at
      t.string :note
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :attendance_change_requests, :users, column: :superior_id
    add_index :attendance_change_requests, :superior_id
  end
end
