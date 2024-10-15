class RemoveSignOutTimeFromTaAttendances < ActiveRecord::Migration[7.2]  
  def change
    remove_column :ta_attendances, :sign_out_time, :datetime
  end
end
