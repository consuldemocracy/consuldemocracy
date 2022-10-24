require "rails_helper"

describe Banner do
  let(:banner) { build(:banner) }

  describe "Concerns" do
    it_behaves_like "acts as paranoid", :banner
    it_behaves_like "globalizable", :banner
  end

  it "is valid" do
    expect(banner).to be_valid
  end

  it "assigns default values to new banners" do
    banner = Banner.new

    expect(banner.background_color).to be_present
    expect(banner.font_color).to be_present
  end

  describe "scope" do
    describe ".with_active" do
      it "works when UTC date is different", :with_non_utc_time_zone do
        banner = create(:banner, post_started_at: Date.current, post_ended_at: Date.current)

        travel_to((Date.current - 1.day).end_of_day) do
          expect(Banner.with_active).to be_empty
        end

        travel_to(Date.current.beginning_of_day) do
          expect(Banner.with_active).to eq [banner]
        end

        travel_to(Date.current.end_of_day) do
          expect(Banner.with_active).to eq [banner]
        end

        travel_to((Date.current + 1.day).beginning_of_day) do
          expect(Banner.with_active).to be_empty
        end
      end
    end

    describe ".with_inactive" do
      it "works when UTC date is different", :with_non_utc_time_zone do
        banner = create(:banner, post_started_at: Date.current, post_ended_at: Date.current)

        travel_to((Date.current - 1.day).end_of_day) do
          expect(Banner.with_inactive).to eq [banner]
        end

        travel_to(Date.current.beginning_of_day) do
          expect(Banner.with_inactive).to be_empty
        end

        travel_to(Date.current.end_of_day) do
          expect(Banner.with_inactive).to be_empty
        end

        travel_to((Date.current + 1.day).beginning_of_day) do
          expect(Banner.with_inactive).to eq [banner]
        end
      end
    end
  end
end
