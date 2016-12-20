require 'rails_helper'

describe Signature do

  describe "validations" do
    it "should be valid"
    it "should be valid if user exists"
    it "should not be valid if already voted"
    it "should not be valid if not in census"
  end

  describe "#in_census" do
    it "checks for all document_types"
  end

  describe "#verify" do

    describe "valid" do
      it "sets status to verified"
      it "asigns vote to user"
    end

    describe "invalid" do
      it "sets status to error"
      it "does not asign any votes"
    end

  end

  describe "#assign_vote" do

    describe "existing user" do
      it "assigns vote to user"
      it "does not assign vote to user if already voted"
      it "marks the vote as coming from a signature"
    end

    describe "inexistent user" do
      it "creates a user with that document number"
      it "assign the vote to newly created user"
      it "marks the vote as coming from a signature"
    end

  end

end