class RenameDepartmentToAffiliationInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :department, :affiliation
  end
end
