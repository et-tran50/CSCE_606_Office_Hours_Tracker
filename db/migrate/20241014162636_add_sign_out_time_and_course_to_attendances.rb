class AddSignOutTimeAndCourseToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_column :attendances, :sign_out_time, :datetime
    add_column :attendances, :course, :string
  end
end
