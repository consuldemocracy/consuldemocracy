require 'rails_helper'

describe TracksHelper do

  describe "tracking users" do

    it "age" do
      user = create(:user)

      user.date_of_birth = nil
      expect(age(user)).to eq('Desconocida')

      user.date_of_birth = 25.years.ago.beginning_of_year
      expect(age(user)).to eq(25)
    end

    it "gender" do
      user = create(:user)

      user.gender = nil
      expect(gender(user)).to eq("Desconocido")

      user.gender = "female"
      expect(gender(user)).to eq("Mujer")

      user.gender = "male"
      expect(gender(user)).to eq("Hombre")
    end
  end

end