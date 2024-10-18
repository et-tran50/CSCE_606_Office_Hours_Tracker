class AddStartAndEndDateToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :start_date, :date
    add_column :courses, :end_date, :date
  end
end
