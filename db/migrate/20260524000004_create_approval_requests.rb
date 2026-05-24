class CreateApprovalRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :approval_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :superior_id, null: false
      t.date :target_month, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :approval_requests, :users, column: :superior_id
    add_index :approval_requests, :superior_id
  end
end
