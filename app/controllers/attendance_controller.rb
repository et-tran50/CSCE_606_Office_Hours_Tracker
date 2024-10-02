class AttendanceController < ApplicationController
      def mark
        email = params[:email]
        current_time = Time.now
    
        # Save the attendance record
        StudentsAttendance.create(email: email, checkin_date: current_time.to_date, checkin_time: current_time.strftime("%H:%M:%S"))
    
        flash[:notice] = 'Attendance marked successfully!'

        redirect_to user_path(@current_user), notice: 'Attendance marked successfully!'
      end
end
