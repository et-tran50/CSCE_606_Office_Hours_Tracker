# spec/controllers/welcome_controller_spec.rb
# bundle exec rspec spec/controllers/welcome_controller_spec.rb

require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe "GET #index" do
    context "when the user is logged in" do
      before do
        @user = User.create!(uid: "123", provider: "google_oauth2", email: "test@example.com", first_name: "Test", last_name: "User")
        session[:user_id] = @user.id  # Simulate user login by setting the session
      end

      it "redirects to the user's show page with a notice" do
        get :index
        expect(response).to redirect_to(user_path(@user))
        expect(flash[:notice]).to eq("Welcome, back!")
      end
    end

    context "when the user is not logged in" do
      it "renders the index view" do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end
end
