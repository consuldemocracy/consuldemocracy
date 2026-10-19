module Debates
  def create_featured_debates
    3.times { create(:debate, featured_at: Time.current) }
  end
end
