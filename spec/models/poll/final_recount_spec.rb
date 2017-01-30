require 'rails_helper'

describe :final_recount do

  it "should update count_log if count changes" do
    final_recount = create(:poll_final_recount, count: 33)

    expect(final_recount.count_log).to eq("")

    final_recount.count = 33
    final_recount.save
    final_recount.count = 32
    final_recount.save
    final_recount.count = 34
    final_recount.save

    expect(final_recount.count_log).to eq(":33:32")
  end

  it "should update officer_assignment_id_log if count changes" do
    final_recount = create(:poll_final_recount, count: 33)

    expect(final_recount.count_log).to eq("")

    final_recount.count = 33
    final_recount.officer_assignment_id = 1
    final_recount.save

    final_recount.count = 32
    final_recount.officer_assignment_id = 2
    final_recount.save

    final_recount.count = 34
    final_recount.officer_assignment_id = 3
    final_recount.save

    expect(final_recount.officer_assignment_id_log).to eq(":1:2")
  end

end