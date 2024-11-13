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


# seed the Course database
# Course.create(
#   course_number: 'ENGR 102',
#   course_name: 'Engineering Lab I - Computation',
#   instructor_name: 'Niki Ritchey',
#   # semester: 'Fall',
#   # year: 2024,
#   start_date: Date.new(2024, 8, 19),
#   end_date: Date.new(2024, 12, 31)
# )

# Course.create(
#   course_number: 'ENGR 200',
#   course_name: 'Dummy course 1',
#   instructor_name: 'Dummy prof 1',
#   # semester: 'Fall',
#   # year: 2024,
#   start_date: Date.new(2024, 8, 19),
#   end_date: Date.new(2024, 12, 31)
# )


# Course.create(
#   course_number: 'ENGR 300',
#   course_name: 'Dummy course 2',
#   instructor_name: 'Dummy prof 2',
#   # semester: 'Fall',
#   # year: 2024,
#   start_date: Date.new(2024, 8, 19),
#   end_date: Date.new(2024, 12, 31)
# )

# Course.create(
#   course_number: 'ENGR 207',
#   course_name: 'Dummy course 3',
#   instructor_name: 'Dummy prof 4',
#   # semester: 'Fall',
#   # year: 2024,
#   start_date: Date.new(2024, 8, 19),
#   end_date: Date.new(2024, 12, 31)
# )

# Get all student ids
user_ids = User.pluck(:id)
start_date = Date.parse("2024-10-01")
end_date = Date.parse("2024-11-30")

# Create fake attendance records for the TA attendance
150.times do
  user_id = user_ids.sample  # Randomly select a valid student_id
  user = User.find(user_id)  # Find the User object associated with this ID
  random_date = rand(start_date..end_date)
  # Generate a random time between 9:00 and 19:00 (inclusive)
  random_hour = rand(9..19)
  random_minute = rand(0..59)
  random_time = Time.zone.local(random_date.year, random_date.month, random_date.day, random_hour, random_minute)

  TaAttendance.create(
    user_id: user_id,
    sign_in_time: random_time,
    checked_in_names: "#{user.first_name} #{user.last_name}"
  )
end
