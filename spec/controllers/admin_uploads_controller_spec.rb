require 'rails_helper'
require 'csv'

RSpec.describe AdminUploadsController, type: :controller do
  describe 'GET #upload_email' do
    before do
      @user = User.create!(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
      session[:user_id] = @user.id
    end

    it 'returns a successful response' do
      get :upload_email
      expect(response).to be_successful
      expect(response).to render_template(:upload_email)
    end

    it 'assigns @current_user' do
      get :upload_email
      expect(assigns(:current_user)).to eq(@user)
    end
  end

  describe '#valid_email?' do
    let(:controller) { AdminUploadsController.new }

    it 'returns true for valid email addresses' do
      expect(controller.send(:valid_email?, 'user@example.com')).to be true
      expect(controller.send(:valid_email?, 'test.user@domain.co')).to be true
    end

    it 'returns false for invalid email addresses' do
      expect(controller.send(:valid_email?, 'invalid-email')).to be false
      expect(controller.send(:valid_email?, 'user@.com')).to be false
      expect(controller.send(:valid_email?, 'user@domain')).to be false
      expect(controller.send(:valid_email?, '@domain.com')).to be false
      expect(controller.send(:valid_email?, 'user@domain..com')).to be false
    end
  end

  describe 'POST #upload_emails' do
    before do
      @user = User.create!(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
      session[:user_id] = @user.id
    end

    let(:temp_admin_file) { Rails.root.join('tmp', 'temp_admin_emails.csv') }
    let(:temp_ta_file) { Rails.root.join('tmp', 'temp_ta_emails.csv') }

    before do
      # Ensure temp files do not exist
      FileUtils.rm_f(temp_admin_file)
      FileUtils.rm_f(temp_ta_file)
    end

    after do
      # Clean up temp files after tests
      FileUtils.rm_f(temp_admin_file)
      FileUtils.rm_f(temp_ta_file)
    end

    context 'when a valid email is provided' do
      it 'appends email to the target file and sets a success flash message' do
        post :upload_emails, params: { email: 'test@example.com', email_type: 'admin' }

        expect(flash[:notice]).to eq("Email test@example.com added successfully to Admin emails.")
        expect(CSV.read(temp_admin_file, headers: true).map(&:first)).to include('test@example.com')
      end
    end

    context 'when an invalid email is provided' do
      it 'does not append the email and sets an alert flash message' do
        post :upload_emails, params: { email: 'invalid-email', email_type: 'admin' }

        expect(flash[:alert]).to eq("Invalid email format.")
        expect(File.exist?(temp_admin_file)).to be false
      end
    end

    context 'when a valid CSV file is uploaded' do
      it 'overwrites the emails in the target file and sets a success flash message' do
        # Create a temporary CSV file
        csv_data = "email\nvalid1@example.com\nvalid2@example.com"
        temp_file = Tempfile.new([ 'temp', '.csv' ])
        temp_file.write(csv_data)
        temp_file.rewind

        post :upload_emails, params: { file: { io: temp_file, filename: 'temp.csv', content_type: 'text/csv' }, email_type: 'ta' }

        expect(flash[:notice]).to eq("Email file uploaded successfully to Ta emails.")
        emails = CSV.read(temp_ta_file, headers: true).map(&:first)
        expect(emails).to include('valid1@example.com', 'valid2@example.com')

        temp_file.close
        temp_file.unlink  # Deletes the temporary file
      end
    end

    context 'when an invalid file format is uploaded' do
      it 'does not overwrite emails and sets an alert flash message' do
        # Create a temporary text file (not a CSV)
        temp_file = Tempfile.new([ 'temp', '.txt' ])
        temp_file.write("This is a test file.")
        temp_file.rewind

        post :upload_emails, params: { file: { io: temp_file, filename: 'temp.txt', content_type: 'text/plain' }, email_type: 'ta' }

        expect(flash[:alert]).to eq("Invalid file format. Please upload a CSV file.")
        expect(File.exist?(temp_ta_file)).to be false

        temp_file.close
        temp_file.unlink  # Deletes the temporary file
      end
    end

    context 'when no email or file is provided' do
      it 'sets an alert flash message' do
        post :upload_emails, params: { email_type: 'admin' }

        expect(flash[:alert]).to eq("No email or file provided.")
        expect(File.exist?(temp_admin_file)).to be false
      end
    end
  end
end