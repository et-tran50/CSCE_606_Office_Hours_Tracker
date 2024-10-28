require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  before do
    # Set up a user and a course for all the test cases
    @user = User.create!(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")

    @course1 = Course.create!(
      course_number: 'ENGR 102',
      course_name: 'Engineering Lab I - Computation',
      instructor_name: 'Niki Ritchey',
      start_date: Date.new(2024, 8, 19),
      end_date: Date.new(2024, 12, 31)
    )
    
    @course2 = Course.create!(
      course_number: 'ENGR 201',
      course_name: 'Engineering Lab II - Mechanics',
      instructor_name: 'Alex Smith',
      start_date: Date.new(2024, 1, 15),
      end_date: Date.new(2024, 5, 15)
    )

    session[:user_id] = @user.id  # Simulate user login
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to have_http_status(:ok)  # Checks for a 200 response
    end

    it "assigns all courses to @courses" do
      get :index
      expect(assigns(:courses)).to contain_exactly(@course1, @course2)  # Checks if all courses are assigned
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to have_http_status(:ok)  # Checks for a 200 response
    end

    it "assigns a new course to @course" do
      get :new
      expect(assigns(:course)).to be_a_new(Course)  # Ensures @course is a new instance of Course
    end
  end

  describe "POST #create" do
    it "creates a new course and redirects to the index" do
      attributes = {
        course_number: 'ENGR 301',
        course_name: 'Engineering Lab III - Design',
        instructor_name: 'Jane Doe',
        start_date: Date.new(2024, 1, 10),
        end_date: Date.new(2024, 5, 20)
      }

      expect {
        post :create, params: { course: attributes }
      }.to change(Course, :count).by(1)  # Expect the count to increase by 1

      expect(response).to redirect_to(courses_path)  # Expect redirection to the index page
      expect(flash[:notice]).to eq('Course was successfully created.')  # Expect the flash message
    end

    it "does not create a new course and re-renders the new template with incomplete attributes" do
      # Simulate invalid attributes (e.g., missing required fields)
      invalid_attributes = {
        course_number: nil,  # Set a field that would normally fail validation
        course_name: 'Invalid Course'
      }

      expect {
        post :create, params: { course: invalid_attributes }
      }.not_to change(Course, :count)  # Expect the count to remain unchanged

      expect(response).to render_template(:new)  # Expect to render the new template
      expect(assigns(:course)).to be_a_new(Course)  # Ensure @course is a new instance of Course
    end
  end

  describe "PATCH #update" do
    before do
      # Assuming you have a course already created
      @course = Course.create!(
        course_number: 'ENGR 102',
        course_name: 'Engineering Lab I - Computation',
        instructor_name: 'Niki Ritchey',
        start_date: Date.new(2024, 8, 19),
        end_date: Date.new(2024, 12, 31)
      )
    end

    context "with valid attributes" do
      it "updates the course and redirects to the show page" do
        updated_attributes = {
          course_number: 'ENGR 102',
          course_name: 'Updated Course Name',
          instructor_name: 'Updated Instructor',
          start_date: Date.new(2024, 8, 20),
          end_date: Date.new(2024, 12, 30)
        }

        patch :update, params: { id: @course.id, course: updated_attributes }

        @course.reload  # Reload the course to get updated attributes
        expect(@course.course_name).to eq('Updated Course Name')  # Check if the name is updated
        expect(response).to redirect_to(@course)  # Expect redirection to the course show page
        expect(flash[:notice]).to eq('Course was successfully updated.')  # Check flash notice
      end
    end

    context "with invalid attributes" do
      it "does not update the course and re-renders the edit template" do
        invalid_attributes = {
          course_number: nil,  # Set a field that would normally fail validation
          course_name: 'Invalid Course'
        }

        patch :update, params: { id: @course.id, course: invalid_attributes }

        expect(@course.course_name).to eq('Engineering Lab I - Computation')  # Ensure name is unchanged
        expect(response).to render_template(:edit)  # Expect to re-render the edit template
        expect(assigns(:course)).to eq(@course)  # Ensure @course is still the same instance
      end
    end
  end

  describe "DELETE #destroy" do
  it "destroys the course and redirects to the index" do
    expect {
      delete :destroy, params: { id: @course1.id }
    }.to change(Course, :count).by(-1)  # Expect the count to decrease by 1

    expect(response).to redirect_to(courses_path)  # Expect redirection to the index page
    expect(flash[:notice]).to eq('Course was successfully destroyed.')  # Check flash notice
  end
end
end
