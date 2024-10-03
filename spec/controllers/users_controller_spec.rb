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
