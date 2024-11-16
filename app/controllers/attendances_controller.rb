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
                  type: "text/csv; charset=UTF-8",
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
    # name = user.full_name()
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
    # puts "course_id: #{params[:course_id]}"
    # puts "start_date: #{params[:start_date]}"
    # puts "end_date: #{params[:end_date]}"
    # Retrieve the course ID, start date, and end date from the request parameters
    course_id = params[:course_id]
    start_date = params[:start_date]
    end_date = params[:end_date]

    # Initialize the data structure for the histogram, with labels for x-axis and values for y-axis
    data = {
      labels: [], # Stores hour labels (e.g., "8 AM", "9 AM") for x-axis
      values: [], # Stores corresponding attendance counts for y-axis
      raw_attendances: [] # Stores raw attendance data for table
    }

    # Loop through each hour from 8 AM to 8 PM to calculate attendance counts per hour
    (8..19).each do |hour|
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
      daily_attendances = hourly_sign_in_count(course_id, start_date, end_date, start_time, end_time)
      if daily_attendances.count > 0
        daily_attendances.each do |attendance|
            data[:raw_attendances] << attendance
        end
      end
      data[:values] << daily_attendances.count # Add the count to the values array
    end

    data[:raw_attendances] = data[:raw_attendances].sort_by do |attendance|
        [ attendance[:course_id],  attendance[:sign_in_time].hour, attendance[:sign_in_time].min, attendance[:sign_in_time].sec, attendance[:sign_in_time].year, attendance[:sign_in_time].month, attendance[:sign_in_time].day ]
    end
    # puts "data: #{data}"

    # Render the data as JSON to send it to the frontend for display
    render json: data
  end

  private


  def handle_attendance(user, role, course_number)
    if attendance_marked_recently?(user, role)
      flash[:warning] = "Attendance already marked for the time slot"
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

  def filter_attendances(model: Attendance)
    attendances = model.all
    # attendances = attendances.where(course_id: params[:course_id]) if params[:course_id].present?

    # filter the data if the model contains course_id column, so it currently applies to attendance of student
    if model.column_names.include?("course_id") && params[:course_id].present?
      # If the parameters of course_id includes "All Courses", don't do any filtering
      if params[:course_id].to_s.include?("All Courses")
        attendances = attendances.all
      else
        # Filter attendances based on the given course_id
        attendances = attendances.where(course_id: params[:course_id])
      end
    end

    attendances = attendances.where("#{model.table_name}.sign_in_time >= ?", params[:start_date].to_date.beginning_of_day) if params[:start_date].present?
    attendances = attendances.where("#{model.table_name}.sign_in_time <= ?", params[:end_date].to_date.end_of_day) if params[:end_date].present?
    attendances
  end

  def generate_student_attendance_csv_count
    # Shows how many students showed up at each hour
    attendances = filter_attendances.joins(:user).where(users: { role: "student" })

    puts "number of attendance with students role" + attendances.count.to_s

    # Convert time zone to CST
    time_zone = ActiveSupport::TimeZone["Central Time (US & Canada)"]

    # Define the date range given from attendance sheet
    start_date = params[:start_date].present? ? params[:start_date].to_date : Date.today
    end_date = params[:end_date].present? ? params[:end_date].to_date : Date.today

    CSV.generate(headers: true, encoding: "UTF-8") do |csv|
      csv << [ "Date", "Time Slot", "Number of Students" ]

      # Loop through each day
      (start_date..end_date).each do |date|
        # Loop through each hour from 9:00 AM to 10:00 PM (up to 17:00)
        (9..16).each do |hour|
          start_time = date.to_time.change(hour: hour).utc
          end_time = start_time + 1.hour

          # start_time = time_zone.parse("#{date} #{hour}:00")
          # end_time = start_time + 1.hour
          # Count the number of students in that time range
          count = attendances.where("attendances.sign_in_time >= ? AND attendances.sign_in_time < ?", start_time, end_time).count

          cst_start_time = start_time.in_time_zone(time_zone)
          cst_end_time = end_time.in_time_zone(time_zone)

          # Add a row to the CSV for each time slot
          csv << [ date.strftime("%Y-%m-%d"), "#{cst_start_time.strftime('%H:%M')} - #{cst_end_time.strftime('%H:%M')} CST", count ]
        end
      end
    end
  end

  def generate_ta_attendance_csv_count
    # Shows how many TAs showed up at each hour
    attendances = filter_attendances(model: TaAttendance)
    time_zone = ActiveSupport::TimeZone["Central Time (US & Canada)"]

    bom = "\uFEFF" # UTF-8 BOM
    csv_data = CSV.generate(headers: true, encoding: "UTF-8") do |csv|
      # Add header row
      csv << [ "Sign-in Time", "Checked-in Names" ]

      # Add data rows
      attendances.each do |attendance|
        cst_signin_time = attendance.sign_in_time.in_time_zone(time_zone).strftime("%Y-%m-%d %H:%M:%S CST")
        csv << [ cst_signin_time, attendance.checked_in_names ]
      end
    end.prepend(bom) # Prepend the BOM to the CSV data
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

def hourly_sign_in_count(course_id, start_date, end_date, hour_start, hour_end)
  # Parse start and end dates
  start_date = Date.parse(start_date)
  end_date = Date.parse(end_date)

  # Define Houston timezone
  houston_timezone = ActiveSupport::TimeZone["Central Time (US & Canada)"]
  daily_attendances = []

  (start_date..end_date).each do |date|
    # Create specific datetime ranges for each day
    start_time = date.in_time_zone(houston_timezone).change(hour: hour_start.split(":")[0].to_i, min: hour_start.split(":")[1].to_i, sec: 0)
    end_time = date.in_time_zone(houston_timezone).change(hour: hour_end.split(":")[0].to_i, min: hour_end.split(":")[1].to_i, sec: 0)

    # Retrieve records for each day within the specified time range
    if course_id == "All Courses"
      daily_attendances += Attendance
                    .where(sign_in_time: start_time..end_time)
    else
      daily_attendances += Attendance
                    .where(course_id: course_id)
                    .where(sign_in_time: start_time..end_time)
    end
  end
  daily_attendances
end
