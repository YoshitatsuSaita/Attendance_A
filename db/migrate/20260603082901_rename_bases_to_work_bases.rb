class RenameBasesToWorkBases < ActiveRecord::Migration[7.1]
  def change
    rename_table :bases, :work_bases
  end
end
