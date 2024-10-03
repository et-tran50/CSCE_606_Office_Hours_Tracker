# spec/models/application_spec.rb

require 'rails_helper'

RSpec.describe "Application Components" do
  describe ApplicationCable::Channel do
    it "is defined" do
      expect(ApplicationCable::Channel).to be_a(Class)
    end
  end

  describe ApplicationCable::Connection do
    it "is defined" do
      expect(ApplicationCable::Connection).to be_a(Class)
    end
  end

  describe ApplicationJob do
    it "is defined" do
      expect(ApplicationJob).to be_a(Class)
    end

    it "inherits from ActiveJob::Base" do
      expect(ApplicationJob).to be < ActiveJob::Base
    end
  end

  describe ApplicationMailer do
    it "is defined" do
      expect(ApplicationMailer).to be_a(Class)
    end

    it "inherits from ActionMailer::Base" do
      expect(ApplicationMailer).to be < ActionMailer::Base
    end

    it "has a default from address" do
      expect(ApplicationMailer.default[:from]).to eq("from@example.com")
    end
  end
end
