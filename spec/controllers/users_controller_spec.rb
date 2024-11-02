# bundle exec rspec spec/controllers/users_controller_spec.rb

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    before do
      mock_google_oauth2  # Mock the Google OAuth2 response
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
      @user = User.find_or_create_by(uid: request.env["omniauth.auth"]["uid"], provider: request.env["omniauth.auth"]["provider"]) do |u|
        u.email = request.env["omniauth.auth"]["info"]["email"]
        names = request.env["omniauth.auth"]["info"]["name"].split
        u.first_name = names[0]
        u.last_name = names[1..].join(" ")
      end
      session[:user_id] = @user.id
    end

    context "when user exists" do
      it "assigns the requested user to @current_user" do # Simulating a GET request to the show action
        get :show, params: { id: @user.id }
        expect(assigns(:current_user)).to eq(@user)
      end

      it "renders the show template" do
        get :show, params: { id: @user.id }
        expect(response).to render_template(:show)
      end
    end

    context "when user does not exist" do
      it "raises an ActiveRecord::RecordNotFound error" do
        expect {
          get :show, params: { id: 9999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_ta_email) { 'valid_ta@example.com' }
  let(:valid_admin_email) { 'valid_admin@example.com' }
  let(:invalid_email) { 'invalid@example.com' }

  describe '#authorize_access' do
    context 'when current user is valid' do
      it 'allows access' do
        allow(controller).to receive(:current_user_valid?).and_return(true)
        expect(controller).not_to receive(:redirect_to)
        controller.send(:authorize_access)
      end
    end

    context 'when current user is invalid' do
      it 'redirects to root path with an alert' do
        allow(controller).to receive(:current_user_valid?).and_return(false)
        expect(controller).to receive(:redirect_to).with(root_path, alert: "Access denied.")
        controller.send(:authorize_access)
      end
    end
  end

  describe '#current_user_valid?' do
    context 'when current_user exists' do
      let(:current_user) { double('User', email: 'test@example.com') }

      before do
        controller.instance_variable_set(:@current_user, current_user)
      end

      context 'when action is showTA' do
        before { allow(controller).to receive(:action_name).and_return('showTA') }

        it 'calls ta_email? method' do
          expect(controller).to receive(:ta_email?).with(current_user.email)
          controller.send(:current_user_valid?)
        end
      end

      context 'when action is showAdmin' do
        before { allow(controller).to receive(:action_name).and_return('showAdmin') }

        it 'calls admin_email? method' do
          expect(controller).to receive(:admin_email?).with(current_user.email)
          controller.send(:current_user_valid?)
        end
      end

      context 'when action is neither showTA nor showAdmin' do
        before { allow(controller).to receive(:action_name).and_return('other_action') }

        it 'returns true' do
          expect(controller.send(:current_user_valid?)).to be true
        end
      end
    end

    context 'when current_user is nil' do
      before do
        controller.instance_variable_set(:@current_user, nil)
      end

      it 'returns false' do
        expect(controller.send(:current_user_valid?)).to be false
      end
    end
  end

  describe '#ta_email?' do
    it 'returns true for valid TA email' do
      allow(controller).to receive(:ta_emails).and_return([ valid_ta_email ])
      expect(controller.send(:ta_email?, valid_ta_email)).to be true
    end

    it 'returns false for invalid TA email' do
      allow(controller).to receive(:ta_emails).and_return([ valid_ta_email ])
      expect(controller.send(:ta_email?, invalid_email)).to be false
    end
  end

  describe '#admin_email?' do
    it 'returns true for valid admin email' do
      allow(controller).to receive(:admin_emails).and_return([ valid_admin_email ])
      expect(controller.send(:admin_email?, valid_admin_email)).to be true
    end

    it 'returns false for invalid admin email' do
      allow(controller).to receive(:admin_emails).and_return([ valid_admin_email ])
      expect(controller.send(:admin_email?, invalid_email)).to be false
    end
  end

  describe '#ta_emails' do
    it 'calls read_emails_from_csv with correct file path' do
      expect(controller).to receive(:read_emails_from_csv).with(Rails.root.join("lib", "ta_emails.csv"))
      controller.send(:ta_emails)
    end
  end

  describe '#admin_emails' do
    it 'calls read_emails_from_csv with correct file path' do
      expect(controller).to receive(:read_emails_from_csv).with(Rails.root.join("lib", "admin_emails.csv"))
      controller.send(:admin_emails)
    end
  end

  describe '#read_emails_from_csv' do
    let(:csv_content) { "email1@example.com\nemail2@example.com\n" }
    let(:file_path) { 'dummy_path.csv' }

    before do
      allow(CSV).to receive(:foreach).and_yield([ 'email1@example.com' ]).and_yield([ 'email2@example.com' ])
    end

    it 'reads emails from CSV file' do
      emails = controller.send(:read_emails_from_csv, file_path)
      expect(emails).to eq([ 'email1@example.com', 'email2@example.com' ])
    end
  end

  # describe 'GET #showAdmin' do
  #   before do
  #     mock_google_oauth2  # Mock the Google OAuth2 response
  #     request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  #     @user = User.find_or_create_by(uid: request.env["omniauth.auth"]["uid"], provider: request.env["omniauth.auth"]["provider"]) do |u|
  #       u.email = request.env["omniauth.auth"]["info"]["email"]
  #       names = request.env["omniauth.auth"]["info"]["name"].split
  #       u.first_name = names[0]
  #       u.last_name = names[1..].join(" ")
  #     end
  #     session[:user_id] = @user.id

  #     # Create the course with the specified details
  #     @course1 = Course.create!(
  #       course_number: 'ENGR 102',
  #       course_name: 'Engineering Lab I - Computation',
  #       instructor_name: 'Niki Ritchey',
  #       start_date: Date.new(2024, 8, 19),
  #       end_date: Date.new(2024, 12, 31)
  #     )

  #     # Create an attendance record linked to the user and course
  #     @attendance = Attendance.create!(
  #       user_id: @user.id,
  #       sign_in_time: Time.current,
  #       course_id: @course1.id  # Ensure this corresponds to the correct course_id field type
  #     )
  #   end

  #   context 'when valid parameters are provided' do
  #     it 'assigns @courses' do
  #       get :showAdmin, params: { course_id: @course1.id }
  #       expect(assigns(:courses)).to include(@course1)
  #     end

  #     it 'assigns @attendances' do
  #       get :showAdmin, params: { course_id: @course1.id }
  #       expect(assigns(:attendances)).to include(@attendance)
  #     end

  #     it 'renders the showAdmin template' do
  #       get :showAdmin, params: { course_id: @course1.id }
  #       expect(response).to render_template(:showAdmin)
  #     end
  #   end

  #   context 'when filtering by course_id' do
  #     it 'filters @attendances by course_id' do
  #       get :showAdmin, params: { course_id: @course1.id }
  #       expect(assigns(:attendances)).to all(have_attributes(course_id: @course1.id))
  #     end
  #   end

  #   context 'when filtering by start_date' do
  #     # Add tests for filtering by start_date
  #   end

  #   context 'when filtering by end_date' do
  #     # Add tests for filtering by end_date
  #   end

  #   context 'when no parameters are provided' do
  #     it 'assigns default values to params' do
  #       get :showAdmin
  #       # Add expectations for default values
  #     end
  #   end
  # end

  # describe 'GET #showAdmin' do
  #   before do
  #     @user = User.create!(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
  #     session[:user_id] = @user.id
  #     # Create sample courses
  #     @course1 = Course.create(course_number: 'CS101', course_name: 'Intro to Computer Science')
  #     @course2 = Course.create(course_number: 'CS102', course_name: 'Data Structures')

  #     # Create sample attendances
  #     @attendance1 = Attendance.create(user_id: @user.id, sign_in_time: Time.now, course_id: @course1.id)
  #     @attendance2 = Attendance.create(user_id: @user.id, sign_in_time: Time.now, course_id: @course2.id)
  #   end
  #   it 'assigns distinct courses to @courses' do
  #     get :showAdmin, params: { id: @user.id, course_id: @course1.id, start_date: '2024-11-01', end_date: '2024-11-01' }
  #     expect(assigns(:courses).pluck(:course_number)).to include(@course1.course_number, @course2.course_number)

  #   end
  # end

    # describe 'GET #showAdmin' do
    #   let!(:course1) { Course.create(course_number: 'CS101', course_name: 'Intro to Computer Science') }
    #   let!(:course2) { Course.create(course_number: 'CS102', course_name: 'Data Structures') }
    #   let!(:attendance1) { Attendance.create(user_id: 1, course_id: course1.course_number, sign_in_time: '2024-10-30 09:00:00') }
    #   let!(:attendance2) { Attendance.create(user_id: 2, course_id: course2.course_number, sign_in_time: '2024-10-31 10:00:00') }
      
    #   before do
    #     # Set up the params for the request
    #     get :showAdmin, params: { course_id: course1.course_number, start_date: '2024-10-30', end_date: '2024-10-30' }
    #   end
  


    #   it 'assigns @courses' do
    #     expect(assigns(:courses)).to include(course1, course2)
    #     expect(assigns(:courses).count).to eq(2)
    #   end
    # end


    describe 'GET #showAdmin' do
    before do
          @user = User.create!(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
          session[:user_id] = @user.id
          # Create sample courses
          @course1 = Course.create(course_number: 'CS101', course_name: 'Intro to Computer Science')
          @course2 = Course.create(course_number: 'CS102', course_name: 'Data Structures')
    
          # Create sample attendances
          @attendance1 = Attendance.create(user_id: @user.id, sign_in_time: Time.now, course_id: @course1.id)
          @attendance2 = Attendance.create(user_id: @user.id, sign_in_time: Time.now, course_id: @course2.id)
      
      # Set up the params for the request
      get :showAdmin, params: { id: @user.id, course_id: @course1.course_number, start_date: '2024-11-01', end_date: '2024-11-01' }
    end
    it 'assigns @courses' do
      expect(assigns(:courses)).to include(@course2.course_number,@course1.course_number)
      expect(assigns(:courses).count).to eq(2)
    end

  end
    

end
