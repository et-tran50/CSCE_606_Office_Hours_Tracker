# app/controllers/admin_uploads_controller.rb
# prompt: make a controller that allows me to take a file or an email address and add it to the files in the lib folder. give me the routes and the upload page using these designs as well.
# response: code below
class AdminUploadsController < ApplicationController
    require "csv"
    def upload_email
    end
    def upload_emails
        email_type = params[:email_type]
        target_file = email_type == "admin" ? "admin_emails.csv" : "ta_emails.csv"
        if params[:email].present?
          email = params[:email].strip
          if valid_email?(email)
            append_email(email, target_file)
            flash[:notice] = "Email #{email} added successfully to #{email_type.capitalize} emails."
          else
            flash[:alert] = "Invalid email format."
          end
        elsif params[:file].present?
          if valid_csv_file?(params[:file])
            overwrite_emails(params[:file], target_file)
            flash[:notice] = "Email file uploaded successfully to #{email_type.capitalize} emails."
          else
            flash[:alert] = "Invalid file format. Please upload a CSV file."
          end
        else
          flash[:alert] = "No email or file provided."
        end

        redirect_to upload_email_path
    end

    private

    def valid_email?(email)
      /\A[^@\s]+@([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}\z/.match?(email)
    end


    def append_email(email, target_file)
      path = Rails.root.join("lib", target_file)

      # see if the last line of file contains the newline element
      File.open(path, "a") do |file|
        file.puts("") unless file.size.zero? || File.read(path).end_with?("\n")
      end

      # Open the file in append mode
      File.open(path, "a+") do |file|
        # Append the email followed by a comma and newline
        file.puts("#{email},")
      end
    end


    def overwrite_emails(file, target_file)
      puts file
      emails = CSV.read(file.path).flatten.map { |email| email.to_s.strip }.reject(&:empty?) # Convert nil to string and strip
      # CSV.open(Rails.root.join("lib", target_file), "w") do |csv|
      #   emails.each do |email|
      #     csv << ["#{email},"]  # Add a comma after each email
      #   end
      # end

      File.open(Rails.root.join("lib", target_file), "w") do |file|
        emails.each do |email|
          file.puts "#{email},"  # Add a comma after each email
        end
      end
    end

    def valid_csv_file?(file)
      file.content_type == "text/csv" || file.content_type == "application/vnd.ms-excel"
      # file[:content_type] == "text/csv" || file[:content_type] == "application/vnd.ms-excel"
    end
end
