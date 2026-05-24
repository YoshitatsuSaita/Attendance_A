class CreateBases < ActiveRecord::Migration[7.1]
  def change
    create_table :bases do |t|
      t.string :base_number, null: false
      t.string :name, null: false
      t.integer :attendance_type, default: 0, null: false

      t.timestamps
    end
  end
end
