class UsersController < ApplicationController
  before_action :set_current_user, only: [:show, :showTA, :showAdmin]
  before_action :authorize_access, only: [:showTA, :showAdmin]

  # user gets set above for all, so nothing is in controller
  def show
  end

  def showTA 
  end

  def showAdmin
  end


  #I asked chat to add security checks so that a student couldn't access the url unless in the file
  private

  def set_current_user
    @current_user = User.find(params[:id])
  end

  def authorize_access
    unless current_user_valid?
      redirect_to root_path, alert: "Access denied."
    end
  end

  def current_user_valid?
    # Check if the current user's email is valid for TA or Admin
    if action_name == 'showTA'
      ta_email?(@current_user.email)
    elsif action_name == 'showAdmin'
      admin_email?(@current_user.email)
    else
      true 
    end
  end

  def ta_email?(email)
    ta_emails.include?(email)
  end

  def admin_email?(email)
    admin_emails.include?(email)
  end

  def ta_emails
    File.read(Rails.root.join('lib', 'ta_emails.txt')).split("\n").map(&:strip)
  end

  def admin_emails
    File.read(Rails.root.join('lib', 'admin_emails.txt')).split("\n").map(&:strip)
  end
end

