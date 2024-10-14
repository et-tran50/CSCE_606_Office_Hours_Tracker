class CreateTaAttendances < ActiveRecord::Migration[7.2]
  def change
    create_table :ta_attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :sign_in_time
      # t.datetime :sign_out_time
      # t.string :course

      t.timestamps
    end
  end
end
