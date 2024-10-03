# spec/controllers/application_controller_spec.rb
# bundle exec rspec spec/controllers/application_controller_spec.rb

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :require_login

    def index
      render plain: "Success"
    end
  end

  describe "GET #index" do
    context "when the user is not logged in" do # def require_login
      it "redirects to the welcome page with an alert" do
        get :index  # Simulate a request to the index action
        expect(response).to redirect_to(welcome_path)
        expect(flash[:alert]).to eq("You must be logged in to access this section.")
      end
    end

    context "when the user is logged in" do
      before do
        @user = User.create!(uid: "123", provider: "google_oauth2", email: "test@example.com", first_name: "Test", last_name: "User")
        session[:user_id] = @user.id
      end

      it "returns the current_user" do
        get :index
        expect(controller.send(:current_user)).to eq(@user)
      end

      it "confirms the user is logged in" do
        get :index
        expect(controller.send(:logged_in?)).to be_truthy
      end
    end
  end
end
