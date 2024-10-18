class AddCourseIdToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_column :attendances, :course_id, :string
  end
end
