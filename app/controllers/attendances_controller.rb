class AttendancesController < ApplicationController
    require 'csv'

    def export_csv
      # Send the generated CSV file to the user
      send_data Attendance.to_csv, filename: "attendance_report.csv"
    end
end
