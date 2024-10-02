# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "when trying to login" do
    it "logs me in" do
      
  end
  describe 'when trying to logout' do
    it 'logs me out' do
      expect(flash[:notice]).to match(/You are logged out/)
    end
  end
end
