# bundle exec rspec ./spec/controllers/attendence_controller_spec.rb

require 'rails_helper'





RSpec.describe AttendancesController, type: :controller do
  before do
    # Set up a user and a course for all the test cases
    @user = User.create(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
    

    @course = Course.create(
      course_number: 'ENGR 102',
      course_name: 'Engineering Lab I - Computation',
      instructor_name: 'Niki Ritchey',
      start_date: Date.new(2024, 8, 19),
      end_date: Date.new(2024, 12, 31)
    )
    
    session[:user_id] = @user.id
  end

  
  describe "#generate_student_attendance_csv" do
    before do
      @user2 = User.create(uid: "123458789", provider: "google_oauth2", email: "user2@example.com", first_name: "John", last_name: "Doe2", role:"student")
      @course2 = Course.create(
      course_number: 'ENGR 103',
      course_name: 'Engineering Lab II - Computation',
      instructor_name: 'Niki Ritchey',
      start_date: Date.new(2025, 8, 19),
      end_date: Date.new(2025, 12, 31)
    )
      @student_attendance = Attendance.create(user: @user2, course_id: @course2.id, sign_in_time: Time.zone.local(2024, 6, 1, 10, 30))
    end

    it "generates a CSV with student attendance records" do

      #puts "All Attendances: #{Attendance.all.inspect}"
      allow(controller).to receive(:filter_attendances).and_return(Attendance.all)
      
      csv_data = controller.send(:generate_student_attendance_csv)
      csv = CSV.parse(csv_data, headers: true)

      expect(csv.headers).to eq(["Student Name", "Course", "Date", "Time"])
    end
  end

  describe "#generate_ta_attendance_csv" do
    it "generates a CSV with TA attendance records" do
      allow(controller).to receive(:filter_attendances).and_return(Attendance.all)
      
      csv_data = controller.send(:generate_ta_attendance_csv)
      csv = CSV.parse(csv_data, headers: true)

      expect(csv.headers).to eq(["TA Name", "Course", "Date", "Time"])
    end
  end


  describe "GET #attendance" do
  before do
    @user = User.create(uid: "123456789", provider: "google_oauth2", email: "user2@example.com", first_name: "John", last_name: "Doe")
    @course = Course.create(course_number: "CS101", course_name: "Introduction to Computer Science")
    session[:user_id] = @user.id
    
    # Create attendances for testing
    @attendance1 = Attendance.create(user_id: @user.id, course_id: @course.id, sign_in_time: 2.days.ago)
    @attendance2 = Attendance.create(user_id: @user.id, course_id: @course.id, sign_in_time: 1.day.ago)
    @attendance3 = Attendance.create(user_id: @user.id, course_id: @course.id, sign_in_time: Time.now)
  end

  it 'sends the filtered attendance report as a CSV file' do
    get :attendance, params: {
      attendance_type: 'student',
      course_id: @course.id,
      start_date: 1.day.ago.to_date,
      end_date: Date.today
    }, format: :csv

    expect(response.headers['Content-Type']).to include 'text/csv'
    expect(response.headers['Content-Disposition']).to include 'attachment'
    expect(response.headers['Content-Disposition']).to include "student_attendance_#{Date.today.strftime('%Y%m%d')}.csv"
    
    # Check if the CSV contains the expected data
    csv_content = response.body
    expect(csv_content).to include "Date"
    expect(csv_content). to include "Number of Students"
  end


  it "generates a CSV with TA attendance count" do

    get :attendance, params: {
      attendance_type: 'ta',
      course_id: @course.id,
      start_date: 1.day.ago.to_date,
      end_date: Date.today
    }, format: :csv
    # Set the time zone for consistent testing

    expect(response.headers['Content-Type']).to include 'text/csv'
    expect(response.headers['Content-Disposition']).to include 'attachment'
  end

  it "returns invalid type error" do

    expect {
      # Replace with the actual method that raises the ArgumentError
      get :attendance, params: {
        attendance_type: 'dummy',
        course_id: @course.id,
        start_date: 1.day.ago.to_date,
        end_date: Date.today
      }, format: :csv
    }.to raise_error(ArgumentError, "Invalid attendance type")

  end
end


  describe '#mark' do
    context 'when the user is a TA' do
      before do
        allow_any_instance_of(AttendancesController).to receive(:ta_email?).with(@user.email).and_return(true)
      end

      it 'marks TA attendance when not marked recently' do
        allow_any_instance_of(AttendancesController).to receive(:attendance_marked_recently?).with(@user, "ta").and_return(false)

        expect {
          post :mark, params: { email: @user.email, course_number: @course.course_number }
        }.to change(TaAttendance, :count).by(1)

        expect(flash[:notice]).to eq("TA attendance marked successfully!")
        expect(session[:attendance_marked]).to be true
      end

      it 'does not mark TA attendance when already marked' do
        allow_any_instance_of(AttendancesController).to receive(:attendance_marked_recently?).with(@user, "ta").and_return(true)

        post :mark, params: { email: @user.email, course_number: @course.course_number }

        expect(flash[:notice]).to eq("Attendance already marked for the time slot")
        expect(session[:attendance_marked]).to be_nil
      end
    end

    context 'when the user is a student' do
      before do
        allow_any_instance_of(AttendancesController).to receive(:ta_email?).with(@user.email).and_return(false)
      end

      it 'marks student attendance when not marked recently' do
        allow_any_instance_of(AttendancesController).to receive(:attendance_marked_recently?).with(@user, "student").and_return(false)

        expect {
          post :mark, params: { email: @user.email, course_number: @course.course_number }
        }.to change(Attendance, :count).by(1)

        # Fix: Compare course_id with @course.id instead of course_number
        expect(Attendance.last.course_id.to_i).to eq(@course.id)
        expect(flash[:notice]).to eq("Student attendance marked successfully!")
        expect(session[:stu_attendance_marked]).to be true
      end

      it 'does not mark student attendance when already marked' do
        allow_any_instance_of(AttendancesController).to receive(:attendance_marked_recently?).with(@user, "student").and_return(true)

        post :mark, params: { email: @user.email, course_number: @course.course_number }

        expect(flash[:notice]).to eq("Attendance already marked for the time slot")
        expect(session[:stu_attendance_marked]).to be_nil
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
