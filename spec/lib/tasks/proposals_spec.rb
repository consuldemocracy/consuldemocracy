require "rails_helper"

describe Proposals do

  describe "Move external_url to description" do

    let :run_rake_task do
      Rake::Task["proposals:move_external_url_to_description"].reenable
      Rake.application.invoke_task "proposals:move_external_url_to_description"
    end

    context "Move external_url to description for Proposals" do

      it "When proposal has external_url" do
        proposal = create(:proposal, description: "<p>Lorem ipsum dolor sit amet</p>",
                                     external_url: "http://consul.dev")

        run_rake_task
        proposal.reload

        expect(proposal.description).to eq "<p>Lorem ipsum dolor sit amet</p> "\
                                           '<p><a href="http://consul.dev" '\
                                           'target="_blank" rel="nofollow">'\
                                           "http://consul.dev</a></p>"
        expect(proposal.external_url).to eq ""
      end

      it "When proposal has not external_url" do
        proposal = create(:proposal, description: "<p>Lorem ipsum dolor sit amet</p>",
                                     external_url: "")

        run_rake_task
        proposal.reload

        expect(proposal.description).to eq "<p>Lorem ipsum dolor sit amet</p>"
        expect(proposal.external_url).to eq ""
      end
    end

    context "Move external_url to description for Legislation proposals" do

      it "When legislation proposal has external_url" do
        legislation_proposal = create(:legislation_proposal, description: "<p>Ut enim ad minim</p>",
                                       external_url: "http://consulproject.org")
        run_rake_task
        legislation_proposal.reload

        expect(legislation_proposal.description).to eq "<p>Ut enim ad minim</p> "\
                                                       '<p><a href="http://consulproject.org" '\
                                                       'target="_blank" rel="nofollow">'\
                                                       "http://consulproject.org</a></p>"
        expect(legislation_proposal.external_url).to eq ""
      end

      it "When legislation proposal has not external_url" do
        legislation_proposal = create(:legislation_proposal, description: "<p>Ut enim ad minim</p>",
                                       external_url: "")
        run_rake_task
        legislation_proposal.reload

        expect(legislation_proposal.description).to eq "<p>Ut enim ad minim</p>"
        expect(legislation_proposal.external_url).to eq ""
      end
    end
  end
end
