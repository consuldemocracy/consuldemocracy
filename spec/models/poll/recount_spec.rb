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
    poll_officer_assignment_1 = create(:poll_officer_assignment)
    recount.officer_assignment = poll_officer_assignment_1
    recount.save

    recount.count = 32
    poll_officer_assignment_2 = create(:poll_officer_assignment)
    recount.officer_assignment = poll_officer_assignment_2
    recount.save

    recount.count = 34
    poll_officer_assignment_3 = create(:poll_officer_assignment)
    recount.officer_assignment = poll_officer_assignment_3
    recount.save

    expect(recount.officer_assignment_id_log).to eq(":#{poll_officer_assignment_1.id}:#{poll_officer_assignment_2.id}")
  end

end
