class Attendance < ApplicationRecord
  belongs_to :student
  validates :sign_in_time, presence: true  # Ensure sign-in time is present

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Date", "Time Slot", "Number of Students"]

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
          count = Attendance.where(sign_in_time: start_time..end_time).count
          # Add a row to the CSV for each time slot
          csv << [date.strftime('%Y-%m-%d'), "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}", count]
        end
      end
    end
  end

end
