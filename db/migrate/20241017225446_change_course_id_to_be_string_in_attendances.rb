class ChangeCourseIdToBeStringInAttendances < ActiveRecord::Migration[7.2]
  def up
    change_column :attendances, :course_id, :string
  end

end
