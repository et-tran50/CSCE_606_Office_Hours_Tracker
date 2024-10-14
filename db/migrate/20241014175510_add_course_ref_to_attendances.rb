class AddCourseRefToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_reference :attendances, :course, null: false, foreign_key: true
  end
end
