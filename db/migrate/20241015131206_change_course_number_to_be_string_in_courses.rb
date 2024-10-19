class ChangeCourseNumberToBeStringInCourses < ActiveRecord::Migration[7.2]
  def change
    change_column :courses, :course_number, :string
  end
end
