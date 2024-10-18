class AttendancesController < ApplicationController
  require "csv"

  def export_csv
    # Send the generated CSV file to the user
    send_data Attendance.to_csv, filename: "attendance_report.csv"
  end

  def mark
    email = params[:email]
    user = User.find_by(email: email)  # Assuming User is the model associated with the user
    course_number = params[:course_number]

    if user
      if ta_email?(email)  # Check if the user is a TA using the same logic as in SessionsController
        if attendance_marked_recently?(user, "ta")
          flash[:notice] = "Attendance already marked for the time slot"
        else
          # Mark attendance if no recent entry found
          TaAttendance.create(user_id: user.id, sign_in_time: Time.now, course_id: "102-PT")
          session[:attendance_marked] = true
          flash[:notice] = "TA attendance marked successfully!"
        end
      else
        if attendance_marked_recently?(user, "student") # Check for student attendance
          flash[:notice] = "Attendance already marked for the time slot"
        else
          # Mark attendance for Student if no recent entry found
          Attendance.create(user_id: user.id, sign_in_time: Time.now, course_id: course_number)
          session[:stu_attendance_marked] = true
          flash[:notice] = "Student attendance marked successfully!"
        end
      end

      # Rails.logger.info "Attendance marked: #{session[:attendance_marked]}"  # Log to verify

    else
      flash[:alert] = "User not found!"
    end

    redirect_to determine_redirect_path(email, course_number)# , notice: flash[:notice] || "Attendance marking failed."
  end

  private

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
end
