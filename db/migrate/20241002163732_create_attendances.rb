class CreateAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :sign_in_time

      t.timestamps
    end
  end
end
