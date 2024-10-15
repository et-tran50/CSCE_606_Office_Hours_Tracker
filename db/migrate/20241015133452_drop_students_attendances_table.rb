class DropStudentsAttendancesTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :students_attendances
  end
end
