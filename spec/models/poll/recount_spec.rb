require 'rails_helper'

describe :recount do

  it "should update count_log if count changes" do
    recount = create(:poll_recount, count: 33)

    expect(recount.count_log).to eq("")

    recount.count = 33
    recount.save
    recount.count = 32
    recount.save
    recount.count = 34
    recount.save

    expect(recount.count_log).to eq(":33:32")
  end

  it "should update officer_assignment_id_log if count changes" do
    recount = create(:poll_recount, count: 33)

    expect(recount.count_log).to eq("")

    recount.count = 33
    recount.officer_assignment = create(:poll_officer_assignment, id: 11)
    recount.save

    recount.count = 32
    recount.officer_assignment = create(:poll_officer_assignment, id: 12)
    recount.save

    recount.count = 34
    recount.officer_assignment = create(:poll_officer_assignment, id: 13)
    recount.save

    expect(recount.officer_assignment_id_log).to eq(":11:12")
  end

end