class RenameStudentIdToUserIdInAttendances < ActiveRecord::Migration[7.2]
  def change
    rename_column :attendances, :student_id, :user_id
  end
end
