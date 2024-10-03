# frozen_string_literal: true

# bundle exec rspec spec/controllers/sessions_controller_spec.rb

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET /auth/google_oauth2/callback" do
    before do
      mock_google_oauth2
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    end

    context "when the login is successful" do
      it "logs the user in and sets the session" do
        get :omniauth

        user = User.find_by(uid: "123456789", provider: "google_oauth2")
        expect(user).not_to be_nil  # Ensure the user was found
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(user_path(user))  # Redirects to user path
      end
    end
    context "when the login fails" do
      before do
        allow_any_instance_of(User).to receive(:valid?).and_return(false)  # Simulate failure
      end

      it "does not log the user in and redirects to the welcome page with an error message" do
        get :omniauth

        expect(session[:user_id]).to be_nil  # Session is not set
        expect(response).to redirect_to(welcome_path)
        expect(flash[:alert]).to eq("Login failed.")
      end
    end
  end

  describe "GET /logout" do
    before do
      @user = User.create(uid: "123456789", provider: "google_oauth2", email: "user@example.com", first_name: "John", last_name: "Doe")
      session[:user_id] = @user.id
    end

    it "logs the user out and redirects to the welcome page" do
      get :logout

      expect(session[:user_id]).to be_nil  # Ensure the session is cleared
      expect(response).to redirect_to(welcome_path)
    end
  end
end
