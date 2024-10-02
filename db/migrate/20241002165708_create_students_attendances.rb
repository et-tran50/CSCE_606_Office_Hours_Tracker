class CreateStudentsAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :students_attendances do |t|
      t.string :email
      t.date :checkin_date
      t.time :checkin_time

      t.timestamps
    end
  end
end
