class CreateOvertimeRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :overtime_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :superior_id, null: false
      t.date :worked_on, null: false
      t.datetime :scheduled_end_time, null: false
      t.boolean :next_day, default: false, null: false
      t.text :work_content
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :overtime_requests, :users, column: :superior_id
    add_index :overtime_requests, :superior_id
  end
end
