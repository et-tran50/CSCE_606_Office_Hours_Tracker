# bundle exec rspec ./spec/controllers/attendence_controller_spec.rb

require 'rails_helper'

RSpec.describe AttendancesController, type: :controller do
  describe "GET #export_csv" do
  before do
    @user = User.create(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
    session[:user_id] = @user.id
  end

    it "sends the attendance report as a CSV file" do
      Attendance.create(user_id: @user.id, sign_in_time: Time.now)
      get :export_csv
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.header['Content-Disposition']).to include 'attachment; filename="attendance_report.csv"'
    end
  end

  describe "POST #mark" do
    before do
      @user = User.create(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
      session[:user_id] = @user.id
    end

    context "when the user exists" do
      it "marks the attendance and redirects with a notice" do
        post :mark, params: { email: @user.email }  # Simulate marking attendance
        expect(Attendance.last.user_id).to eq(@user.id)  # Check that the attendance was created
        expect(flash[:notice]).to eq("Attendance marked successfully!")
        expect(response).to redirect_to(user_path(@user))  # Check redirection
      end
    end

    context "when the user does not exist" do
      it "does not mark attendance and redirects with an alert" do
        post :mark, params: { email: 'nonexistent@example.com' }  # Simulate marking attendance for a non-existent user
        expect(Attendance.count).to eq(0)  # Check that no attendance record was created
        expect(flash[:alert]).to eq("User not found!")
        expect(response).to redirect_to(user_path(@user))  # Check redirection
      end
    end
  end
end