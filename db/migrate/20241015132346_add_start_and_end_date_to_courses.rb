class AddStartAndEndDateToCourses < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:courses, :start_date)
      add_column :courses, :start_date, :date
    end

    unless column_exists?(:courses, :end_date)
      add_column :courses, :end_date, :date
    end
  end
end
