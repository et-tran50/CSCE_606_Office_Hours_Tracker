class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def current_user
    # if @current _user is undefined or falsy, evaluate the RHS
    #   RHS := look up user by id only if user id is in the session hash
    # question: what happens if session has user_id but DB does not?

    # 2024/11/10: In the commented out version of code, if there is no entry in the database, 
    # a routing error will occur showing that can;t find user with id = 1
    # @current_user ||= User.find_by(session[:user_id]) if session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]

  end

  def logged_in?
    # current_user returns @current_user,
    # which is not nil (truthy) only if session[:user_id] is a valid user id
    current_user
  end

  def require_login
    # redirect to the welcome page unless user is logged in
    unless logged_in?
      redirect_to welcome_path, alert: "You must be logged in to access this section."
    end
  end
end
