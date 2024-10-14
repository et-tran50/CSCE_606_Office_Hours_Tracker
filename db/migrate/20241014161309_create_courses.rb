class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.integer :course_number
      t.string :course_name
      t.string :instructor_name
      # t.string :semester
      # t.integer :year
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
