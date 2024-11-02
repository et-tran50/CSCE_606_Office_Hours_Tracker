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
      CSV.open(Rails.root.join("lib", target_file), "a+", headers: true) do |csv|
        csv << [ email ]  # Wrap email in an array to create a new row
      end
    end


    def overwrite_emails(file, target_file)
      emails = CSV.read(file.path).flatten
      CSV.open(Rails.root.join("lib", target_file), "w") do |csv|
        emails.each do |email|
          csv << [ email ]  # Write each email as a new row
        end
      end
    end

    def valid_csv_file?(file)
      file.content_type == "text/csv" || file.content_type == "application/vnd.ms-excel"
    end
end
