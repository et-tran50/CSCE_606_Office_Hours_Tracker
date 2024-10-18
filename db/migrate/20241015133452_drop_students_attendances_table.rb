class DropStudentsAttendancesTable < ActiveRecord::Migration[7.2]
  def change
    if table_exists?(:students_attendances)
      drop_table :students_attendances
    else
      puts "Table students_attendances does not exist"
    end
  end
end
