class AddCheckedInNamesToTaAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :ta_attendances, :checked_in_names, :text, array: true
  end
end
