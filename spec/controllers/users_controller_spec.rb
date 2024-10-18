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
end
