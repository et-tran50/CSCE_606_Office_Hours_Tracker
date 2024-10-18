class AttendancesController < ApplicationController
    require "csv"

    def attendance
      @courses = Course.all
      @attendances = filter_attendances
    end

    # Send the generated CSV file to the user
    def download_student_attendance
      send_data generate_student_attendance_csv, filename: "student_attendance.csv"
    end

    def download_ta_attendance
      send_data generate_ta_attendance_csv, filename: "ta_attendance.csv"
    end

    def download_student_attendance_test
      send_data generate_student_attendance_csv_test, filename: "student_attendance_test.csv"
    end

    def download_ta_attendance_test
      send_data generate_ta_attendance_csv_test, filename: "ta_attendance_test.csv"
    end

    def mark
      email = params[:email]
      user = User.find_by(email: email)  # Assuming User is the model associated with the user

      if user
        # Save the attendance record
        Attendance.create(user_id: user.id, sign_in_time: Time.now)

        flash[:notice] = "Attendance marked successfully!"
      else
        flash[:alert] = "User not found!"
      end

      redirect_to user_path(@current_user), notice: flash[:notice] || "Attendance marking failed."
    end

    private

    def filter_attendances
      attendances = Attendance.all
      attendances = attendances.where(course_id: params[:course_id]) if params[:course_id].present?
      attendances = attendances.where("created_at >= ?", params[:start_date].to_date.beginning_of_day) if params[:start_date].present?
      attendances = attendances.where("created_at <= ?", params[:end_date].to_date.end_of_day) if params[:end_date].present?
      attendances
    end

    def generate_student_attendance_csv_test
      attendances = filter_attendances.joins(:user).where(users: { role: "student" })

      CSV.generate(headers: true) do |csv|
        csv << [ "Date", "Time Slot", "Number of Students" ]

        # Define the date range from June 1 to June 6, 2024
        start_date = Date.parse("2024-06-01")
        end_date = Date.parse("2024-06-06")

        # Loop through each day
        (start_date..end_date).each do |date|
          # Loop through each hour from 9:00 AM to 4:00 PM (up to 17:00)
          (9..16).each do |hour|
            start_time = Time.zone.parse("#{date} #{hour}:00:00")
            end_time = start_time + 1.hour
            # Count the number of students in that time range
            count = attendance.count
            # Add a row to the CSV for each time slot
            csv << [ date.strftime("%Y-%m-%d"), "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}", count ]
          end
        end
      end
    end

    def generate_ta_attendance_csv_test
      attendances = filter_attendances.joins(:user).where(users: { role: "ta" })

      CSV.generate(headers: true) do |csv|
        csv << [ "Date", "Time Slot", "Number of TAs" ]

        # Define the date range from June 1 to June 6, 2024
        start_date = Date.parse("2024-06-01")
        end_date = Date.parse("2024-06-06")

        # Loop through each day
        (start_date..end_date).each do |date|
          # Loop through each hour from 9:00 AM to 4:00 PM (up to 17:00)
          (9..16).each do |hour|
            start_time = Time.zone.parse("#{date} #{hour}:00:00")
            end_time = start_time + 1.hour
            # Count the number of students in that time range
            count = attendance.count
            # Add a row to the CSV for each time slot
            csv << [ date.strftime("%Y-%m-%d"), "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}", count ]
          end
        end
      end
    end

    def generate_student_attendance_csv
      attendances = filter_attendances.joins(:user).where(users: { role: "student" })

      CSV.generate do |csv|
        csv << [ "Student Name", "Course", "Date", "Time" ]
        attendances.each do |attendance|
          csv << [ attendance.user.full_name, attendance.course.name, attendance.created_at.to_date, attendance.created_at.strftime("%H:%M") ]
        end
      end
    end

    def generate_ta_attendance_csv
      attendances = filter_attendances.joins(:user).where(users: { role: "ta" })

      CSV.generate do |csv|
        csv << [ "TA Name", "Course", "Date", "Time" ]
        attendances.each do |attendance|
          csv << [ attendance.user.full_name, attendance.course.name, attendance.created_at.to_date, attendance.created_at.strftime("%H:%M") ]
        end
      end
    end
end
