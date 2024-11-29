# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# first step seeding
require 'faker'


#########################################################
# section 1:  seed the Course database
Course.create(
  course_number: 'ENGR 102',
  course_name: 'Engineering Lab I - Computation',
  instructor_name: 'Niki Ritchey',
  # semester: 'Fall',
  # year: 2024,
  start_date: Date.new(2024, 8, 19),
  end_date: Date.new(2024, 12, 31)
)

Course.create(
  course_number: 'ENGR 200',
  course_name: 'Dummy course 1',
  instructor_name: 'Dummy prof 1',
  # semester: 'Fall',
  # year: 2024,
  start_date: Date.new(2024, 8, 19),
  end_date: Date.new(2024, 12, 31)
)


Course.create(
  course_number: 'ENGR 300',
  course_name: 'Dummy course 2',
  instructor_name: 'Dummy prof 2',
  # semester: 'Fall',
  # year: 2024,
  start_date: Date.new(2024, 8, 19),
  end_date: Date.new(2024, 12, 31)
)

Course.create(
  course_number: 'ENGR 207',
  course_name: 'Dummy course 3',
  instructor_name: 'Dummy prof 4',
  # semester: 'Fall',
  # year: 2024,
  start_date: Date.new(2024, 8, 19),
  end_date: Date.new(2024, 12, 31)
)
# #################################################################3



##################################################################
# section 2: seed the TA and student database
# After logging with the two identities (students and TA),
# comment out the code in section 1, and uncomment section 2 to do the seeding
# Note: To login as TA or admin, simply append your gmail to the lib/ta_email.csv or lib/student_emails.csv
# The person whose email is not in the TA or Admin csv file will be directed to the student page.

# # Get all student ids
# user_ids = User.pluck(:id)
# start_date = Date.parse("2024-10-01")
# end_date = Date.parse("2024-11-30")

# # Create fake attendance records for the TA attendance
# 150.times do
#   user_id = user_ids.sample  # Randomly select a valid student_id
#   user = User.where(role: "ta").pluck(:id)  # Find the User object associated with this ID
#   random_date = rand(start_date..end_date)
#   # Generate a random time between 9:00 and 19:00 (inclusive)
#   random_hour = rand(9..19)
#   random_minute = rand(0..59)
#   random_time = Time.zone.local(random_date.year, random_date.month, random_date.day, random_hour, random_minute)

#   TaAttendance.create(
#     user_id: user_id,
#     sign_in_time: random_time,
#     checked_in_names: "#{user.first_name} #{user.last_name}"
#   )
# end


# # Generate 50 fake attendance records
# 50.times do
#   Attendance.create(
#     user_id: User.where(role: "student").pluck(:id),
#     course_id: "ENGR 102",
#     sign_in_time: Faker::Time.between(
#       from: DateTime.new(2024, 11, 13, 0, 0, 0),
#       to: DateTime.new(2024, 11, 13, 23, 59, 59)
#     )
#   )
# end
##########################################################################
