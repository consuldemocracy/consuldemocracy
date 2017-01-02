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

end