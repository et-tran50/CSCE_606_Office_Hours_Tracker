class Attendance < ApplicationRecord
  belongs_to :user
  validates :sign_in_time, presence: true  # Ensure sign-in time is present

  # self.to_csv moved to attendance_controller.rb
end
