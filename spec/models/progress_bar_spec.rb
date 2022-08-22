require "rails_helper"

describe ProgressBar do
  let(:progress_bar) { build(:progress_bar) }

  it_behaves_like "globalizable", :progress_bar
  it_behaves_like "globalizable", :secondary_progress_bar

  it "is valid" do
    expect(progress_bar).to be_valid
  end

  it "is valid without a title" do
    progress_bar.title = nil

    expect(progress_bar).to be_valid
  end

  it "is not valid with a custom type" do
    expect { progress_bar.kind = "terciary" }.to raise_exception(ArgumentError)
  end

  it "is not valid without a percentage" do
    progress_bar.percentage = nil

    expect(progress_bar).not_to be_valid
  end

  it "is not valid with a non-numeric percentage" do
    progress_bar.percentage = "High"

    expect(progress_bar).not_to be_valid
  end

  it "is not valid with a non-integer percentage" do
    progress_bar.percentage = 22.83

    expect(progress_bar).not_to be_valid
  end

  it "is not valid with a negative percentage" do
    progress_bar.percentage = -1

    expect(progress_bar).not_to be_valid
  end

  it "is not valid with a percentage bigger than 100" do
    progress_bar.percentage = 101

    expect(progress_bar).not_to be_valid
  end

  it "is valid with an integer percentage within the limits" do
    progress_bar.percentage = 0

    expect(progress_bar).to be_valid

    progress_bar.percentage = 100

    expect(progress_bar).to be_valid

    progress_bar.percentage = 83

    expect(progress_bar).to be_valid
  end

  it "dynamically validates the percentage range" do
    stub_const("#{ProgressBar}::RANGE", (-99..99))

    progress_bar.percentage = -99

    expect(progress_bar).to be_valid

    progress_bar.percentage = 100

    expect(progress_bar).not_to be_valid
  end

  it "is not valid without a progressable" do
    progress_bar.progressable = nil

    expect(progress_bar).not_to be_valid
  end

  it "cannot have another primary progress bar for the same progressable" do
    progress_bar.save!
    duplicate = build(:progress_bar, progressable: progress_bar.progressable)

    expect(duplicate).not_to be_valid
  end

  describe "secondary progress bar" do
    let(:progress_bar) { build(:progress_bar, :secondary) }

    it "is valid" do
      expect(progress_bar).to be_valid
    end

    it "is invalid without a title" do
      progress_bar.title = nil

      expect(progress_bar).not_to be_valid
    end

    it "can have another secondary progress bar for the same progressable" do
      progress_bar.save!
      duplicate = build(:progress_bar, progressable: progress_bar.progressable)

      expect(duplicate).to be_valid
    end
  end
end
