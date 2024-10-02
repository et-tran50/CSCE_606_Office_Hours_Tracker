# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  describe 'when opening the app' do
    it 'current user is none' do
      user = Application.current_user()
      expect(user).to match("No user") #I'm not sure what it says yet this is a place holder
    end
  end
end
