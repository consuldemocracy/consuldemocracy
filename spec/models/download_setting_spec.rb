require "rails_helper"

describe DownloadSetting do
  describe ".csv_for" do
    it "generates CSV for the given resources" do
      create(:budget_investment, :feasible, :selected,
             author: create(:user, username: "Astérix"),
             title: "Le Investment",
             cached_votes_up: 88, price: 99)
      create(:budget_investment, :unfeasible,
             author: create(:user, username: "Obélix"),
             title: "Alt Investment",
             cached_votes_up: 66, price: 88)

      attributes = %i[title cached_votes_up price valuation_finished selected author_name]
      csv_contents = "title,cached_votes_up,price,valuation_finished,selected,author_name\n"\
        "Le Investment,88,99,true,true,Astérix\n"\
        "Alt Investment,66,88,false,false,Obélix\n"

      expect(DownloadSetting.csv_for(Budget::Investment.all, attributes)).to eq(csv_contents)
    end
  end
end
