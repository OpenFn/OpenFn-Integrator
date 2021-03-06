require 'rails_helper'

RSpec.describe Submission::Dispatch, :type => :model do

  let(:submission) { double(Submission, raw_destination_payload: "{raw: {destination: 'payload'}}", integration: integration) }
  let(:integration) { double(Integration, destination_credentials: destination_credentials, destination: destination) }
  let(:destination) { double(Integration::Destination, integration_type: 'TestProduct') }
  let(:destination_credentials) { double(Credential) }

  before(:each) do
    @dispatch = Submission::Dispatch.new
  end

  describe "responsibilities" do

    before(:each) do
      # allow(Resque).to receive(:enqueue)
    end

    it "dispatches the raw destination payload according to the relevant Product Module" do
      pending("This is for functionality that is not yet finished. TODO, ask Stu.")
      allow(submission).to receive(:submitted!)
      expect(Integration::TestProduct).to receive(:submit!).with(submission.raw_destination_payload, destination_credentials)

      @dispatch.perform(submission)
    end

    it "marks the submission record as submitted" do
      pending("This is for functionality that is not yet finished. TODO, ask Stu.")
      allow(Integration::TestProduct).to receive(:submit!)
      expect(submission).to receive(:submitted!)

      @dispatch.perform(submission)
    end
  end  
end
