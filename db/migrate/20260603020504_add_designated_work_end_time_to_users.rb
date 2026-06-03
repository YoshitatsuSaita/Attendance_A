class AddDesignatedWorkEndTimeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :designated_work_end_time, :datetime
  end
end
