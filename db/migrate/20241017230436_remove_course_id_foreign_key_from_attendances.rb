class RemoveCourseIdForeignKeyFromAttendances < ActiveRecord::Migration[7.2]
  def change
    # remove_foreign_key :attendances, :courses
    remove_column :attendances, :course_id
  end
end
