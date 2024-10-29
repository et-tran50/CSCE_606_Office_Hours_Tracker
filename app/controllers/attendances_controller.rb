class AttendancesController < ApplicationController
  require "csv"

  def attendance
    @courses = Course.all
    @attendances = filter_attendances

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_attendance_csv,
                  filename: "#{params[:attendance_type]}_attendance_#{Date.today.strftime('%Y%m%d')}.csv",
                  type: "text/csv",
                  disposition: "attachment"
      end
    end
  end

  # def mark
  #   email = params[:email]
  #   user = User.find_by(email: email)  # Assuming User is the model associated with the user
  #   course_number = params[:course_number]


  #   course = Course.find_by(course_number: course_number)  # Find the course by course_number

  #   if user
  #     if ta_email?(email)  # Check if the user is a TA using the same logic as in SessionsController
  #       if attendance_marked_recently?(user, "ta")
  #         flash[:notice] = "Attendance already marked for the time slot"
  #       else
  #         # Mark attendance if no recent entry found
  #         # 2024/10/18 update: the course_id should actually be course
  #         # , course: "102-PT"
  #         TaAttendance.create(user_id: user.id, sign_in_time: Time.now)
  #         session[:attendance_marked] = true
  #         flash[:notice] = "TA attendance marked successfully!"
  #       end
  #     else
  #       if attendance_marked_recently?(user, "student") # Check for student attendance
  #         flash[:notice] = "Attendance already marked for the time slot"
  #       else
  #         # Mark attendance for Student if no recent entry found
  #         Attendance.create(user_id: user.id, sign_in_time: Time.now, course_id: course.id)
  #         session[:stu_attendance_marked] = true
  #         flash[:notice] = "Student attendance marked successfully!"
  #       end
  #     end

  #     # Rails.logger.info "Attendance marked: #{session[:attendance_marked]}"  # Log to verify

  #   else
  #     flash[:alert] = "User not found!"
  #   end

  #   redirect_to determine_redirect_path(email, course_number)# , notice: flash[:notice] || "Attendance marking failed."
  # end
  def mark
    email = params[:email]
    user = User.find_by(email: email)  # Assuming User is the model associated with the user
    course_number = params[:course_number]

    if user
      if ta_email?(email)
        handle_attendance(user, "ta", course_number)
      else
        handle_attendance(user, "student", course_number)
      end
    else
      flash[:alert] = "User not found!"
    end

    redirect_to determine_redirect_path(email, course_number)
  end

  def calculate_attendance
    puts "course_id: #{params[:course_id]}"
    puts "start_date: #{params[:start_date]}"
    puts "end_date: #{params[:end_date]}"
    # Retrieve the course ID, start date, and end date from the request parameters
    course_id = params[:course_id]
    start_date = params[:start_date]
    end_date = params[:end_date]

    # Initialize the data structure for the histogram, with labels for x-axis and values for y-axis
    data = {
      labels: [], # Stores hour labels (e.g., "8 AM", "9 AM") for x-axis
      values: []  # Stores corresponding attendance counts for y-axis
    }

    # Loop through each hour from 8 AM to 8 PM to calculate attendance counts per hour
    (8..20).each do |hour|
      # Format the hour label (e.g., "8 AM", "12 PM", "5 PM") and add it to labels array
      if hour < 12
        data[:labels] << "#{hour} AM"
      elsif hour == 12
        data[:labels] << "12 PM"
      else
        data[:labels] << "#{hour - 12} PM"
      end

      # Define the start and end times for the current hour range
      start_time = "#{hour}:00:00"
      end_time = "#{hour + 1}:00:00"

      # Get the attendance count for this course, date range, and hour range
      count = hourly_sign_in_count(course_id, start_date, end_date, start_time, end_time)
      data[:values] << count # Add the count to the values array
    end

    # Output the generated data to the console for debugging
    puts "data: #{data}"

    # Render the data as JSON to send it to the frontend for display
    render json: data
  end

  private


  def handle_attendance(user, role, course_number)
    if attendance_marked_recently?(user, role)
      flash[:notice] = "Attendance already marked for the time slot"
    else
      mark_attendance(user, role, course_number)
      session[:attendance_marked] = true
      flash[:notice] = "#{role.capitalize} attendance marked successfully!"
    end
  end

  def mark_attendance(user, role, course_number)
    if role == "ta"
      TaAttendance.create(user_id: user.id, sign_in_time: Time.now)
    else
      Attendance.create(user_id: user.id, sign_in_time: Time.now, course_id: course_number)
    end
  end



  def attendance_marked_recently?(user, role)
    if role == "ta"
      # Check TA attendance within the last hour
      TaAttendance.where(user_id: user.id, sign_in_time: (Time.now - 1.hour)..Time.now).exists?
    else
      # Check Student attendance within the last hour
      Attendance.where(user_id: user.id, sign_in_time: (Time.now - 1.hour)..Time.now).exists?
    end
  end

  def determine_redirect_path(email, course_number)
    if ta_email?(email)
      ta_path(@current_user)
    elsif admin_email?(email)
      admin_path(@current_user)
    else
      user_path(@current_user, course_number: course_number)
    end
  end

  def ta_email?(email)
    ta_emails.include?(email)
  end

  def admin_email?(email)
    admin_emails.include?(email)
  end

  def ta_emails
    read_emails_from_csv(Rails.root.join("lib", "ta_emails.csv"))
  end

  def admin_emails
    read_emails_from_csv(Rails.root.join("lib", "admin_emails.csv"))
  end

  def read_emails_from_csv(file_path)
    emails = []
    CSV.foreach(file_path, headers: false) do |row|
      emails << row[0].strip unless row[0].nil? # Assuming emails are in the first column
    end
    emails
  end

  def generate_attendance_csv
    case params[:attendance_type]
    when "student"
      generate_student_attendance_csv_count
    when "ta"
      generate_ta_attendance_csv_count
    else
      raise ArgumentError, "Invalid attendance type"
    end
  end

  def filter_attendances
    attendances = Attendance.all
    attendances = attendances.where(course_id: params[:course_id]) if params[:course_id].present?
    attendances = attendances.where("created_at >= ?", params[:start_date].to_date.beginning_of_day) if params[:start_date].present?
    attendances = attendances.where("created_at <= ?", params[:end_date].to_date.end_of_day) if params[:end_date].present?
    attendances
  end

  def generate_student_attendance_csv_count
    # Shows how many students showed up at each hour
    attendances = filter_attendances.joins(:user).where(users: { role: "student" })

    # Define the date range given from attendance sheet
    start_date = params[:start_date].present? ? params[:start_date].to_date : Date.today
    end_date = params[:end_date].present? ? params[:end_date].to_date : Date.today

    CSV.generate(headers: true) do |csv|
      csv << [ "Date", "Time Slot", "Number of Students" ]

      # Loop through each day
      (start_date..end_date).each do |date|
        # Loop through each hour from 9:00 AM to 4:00 PM (up to 17:00)
        (9..16).each do |hour|
          start_time = Time.zone.parse("#{date} #{hour}:00:00")
          end_time = start_time + 1.hour
          # Count the number of students in that time range
          count = rand(0..5) # attendance.count
          # Add a row to the CSV for each time slot
          csv << [ date.strftime("%Y-%m-%d"), "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}", count ]
        end
      end
    end
  end

  def generate_ta_attendance_csv_count
    # Shows how many tas showed up at each hour
    attendances = filter_attendances.joins(:user).where(users: { role: "ta" })

    # Define the date range from June 1 to June 6, 2024
    start_date = params[:start_date].present? ? params[:start_date].to_date : Date.today
    end_date = params[:end_date].present? ? params[:end_date].to_date : Date.today

    CSV.generate(headers: true) do |csv|
      csv << [ "Date", "Time Slot", "Number of TAs" ]

      # Loop through each day
      (start_date..end_date).each do |date|
        # Loop through each hour from 9:00 AM to 4:00 PM (up to 17:00)
        (9..16).each do |hour|
          start_time = Time.zone.parse("#{date} #{hour}:00:00")
          end_time = start_time + 1.hour
          # Count the number of students in that time range
          count = rand(0..5) # attendance.count
          # Add a row to the CSV for each time slot
          csv << [ date.strftime("%Y-%m-%d"), "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}", count ]
        end
      end
    end
  end

  def generate_student_attendance_csv
    # Shows each attendance record (basically all entries where someone clicked "I am here")
    attendances = filter_attendances.joins(:user).where(users: { role: "student" })

    CSV.generate do |csv|
      csv << [ "Student Name", "Course", "Date", "Time" ]
      attendances.each do |attendance|
        course_search = Course.find_by(id: attendance.course_id) # course is a foriegn key to attendances, so we need to find the course by index
        csv << [ attendance.user.full_name, course_search.course_name, attendance.created_at.to_date, attendance.created_at.strftime("%H:%M") ]
      end
    end
  end

  def generate_ta_attendance_csv
    # Shows each attendance record
    attendances = filter_attendances.joins(:user).where(users: { role: "ta" })

    CSV.generate do |csv|
      csv << [ "TA Name", "Course", "Date", "Time" ]
      attendances.each do |attendance|
        csv << [ attendance.user.full_name, attendance.course.name, attendance.created_at.to_date, attendance.created_at.strftime("%H:%M") ]
      end
    end
  end
end

def hourly_sign_in_count(course_id, start_date, end_date, hour_start, hour_end)
  # Parse the start and end date strings into Date objects
  start_time = Date.parse(start_date)
  end_time = Date.parse(end_date)

  # Query the Attendance table for entries that match the course ID and are within the specified date and hour range
  Attendance
    .where(course_id: course_id) # Filter by the specified course ID
    .where(sign_in_time: start_time.beginning_of_day..end_time.end_of_day) # Filter by the date range from start to end date
    .where("strftime('%H:%M', sign_in_time) >= ? AND strftime('%H:%M', sign_in_time) < ?", hour_start, hour_end) # Filter by the hour range
    .count # Return the total count of matching records
end
