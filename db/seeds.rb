# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Create 50 fake students
50.times do
  Student.create(
    name: Faker::Name.name,
    email: Faker::Internet.email
  )
end

# Get all student ids
student_ids = Student.pluck(:id)
start_date = Date.parse("2024-06-01")
end_date = Date.parse("2024-06-06")

# Create fake attendance records for these students
200.times do
  student_id = student_ids.sample  # Randomly select a valid student_id
  # Generate a random date between June 1 and June 6
  random_date = rand(start_date..end_date)
  # Generate a random time between 9:00 and 17:00 (inclusive)
  random_hour = rand(9..16)
  random_minute = rand(0..59)
  random_time = Time.zone.local(random_date.year, random_date.month, random_date.day, random_hour, random_minute)

  Attendance.create(
    student_id: student_id,
    sign_in_time: random_time
  )
end