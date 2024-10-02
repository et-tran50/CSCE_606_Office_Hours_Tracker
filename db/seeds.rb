# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
StudentsAttendance.destroy_all

# Seed data
StudentsAttendance.create([
  { email: 'james@tamu.edu', checkin_date: '2024-10-01', checkin_time: '09:00:00' },
  { email: 'sara@tamu.edu', checkin_date: '2024-10-01', checkin_time: '09:15:00' },
  { email: 'bran@tamu.edu', checkin_date: '2024-10-01', checkin_time: '09:30:00' },
  { email: 'jolly@tamu.edu', checkin_date: '2024-10-02', checkin_time: '10:00:00' },
  { email: 'jack@tamu.edu', checkin_date: '2024-10-02', checkin_time: '10:15:00' }
])

# attendance = StudentsAttendance.find(1) # replace 1 with the actual ID
# puts "Email: #{attendance.email}, Checkin Date: #{attendance.checkin_date}, Checkin Time: #{attendance.checkin_time.strftime("%H:%M:%S")}"