class RenameStudentsToUsers < ActiveRecord::Migration[7.2]
  def change
    rename_table :students, :users
  end
end
