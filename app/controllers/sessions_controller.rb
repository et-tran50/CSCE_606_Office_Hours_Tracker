class SessionsController < ApplicationController
  require "csv"
  skip_before_action :require_login, only: [ :omniauth ]
  # GET /logout
  def logout
    reset_session
    redirect_to welcome_path # , notice: "You are logged out."
  end

  # GET /auth/google_oauth2/callback
  def omniauth
    auth = request.env["omniauth.auth"]
    @user = User.find_or_create_by(uid: auth["uid"], provider: auth["provider"]) do |u|
      u.email = auth["info"]["email"]
      names = auth["info"]["name"].split
      u.first_name = names[0]
      u.last_name = names[1..].join(" ")
    end

    if @user.valid?
      session[:user_id] = @user.id
      redirect_to determine_redirect_path(@user.email)# , notice: "You are logged in."
    else
      redirect_to welcome_path, alert: "Login failed."
    end
  end

  # the code below determines based on the email address what page the user should go to. if the user is in admin.txt or ta.txt found in the
  # lib file, they will go there.
  # prompt: check the email address logged in with and redirect it to a ta page, student page, or admin page
  # depending on whether the email address is in the admin email list or the ta email list.
  # response: code below (modified to fit the user id requirements)
  private

  def determine_redirect_path(email)
    if ta_email?(email)
      ta_path(@user)
    elsif admin_email?(email)
      admin_path(@user, Date.today)
    else
      user_path(@user)
    end
  end

  def ta_email?(email)
    ta_emails.include?(email)
  end

  def admin_email?(email)
    admin_emails.include?(email)
  end

  def ta_emails
    read_emails_from_csv(Rails.root.join("lib", "ta_emails.csv"))
  end

  def admin_emails
    read_emails_from_csv(Rails.root.join("lib", "admin_emails.csv"))
  end

  def read_emails_from_csv(file_path)
    emails = []
    CSV.foreach(file_path, headers: false) do |row|
      emails << row[0].strip unless row[0].nil? # Assuming emails are in the first column
    end
    emails
  end
end
