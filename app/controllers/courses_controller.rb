class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  def index
    @courses = Course.all
  end

  # GET /courses/:id
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # POST /courses
  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to courses_path, notice: 'Course was successfully created.'  # Redirect to index page
    else
      render :new
    end
  end

  # GET /courses/:id/edit
  def edit
  end

  # PATCH/PUT /courses/:id
  def update
    if @course.update(course_params)
      redirect_to @course, notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /courses/:id
  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  private

  # Set the course for actions
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a list of trusted parameters
  def course_params
    params.require(:course).permit(:course_number, :course_name, :instructor_name, :start_date, :end_date)
  end
end
