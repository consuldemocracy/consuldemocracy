require 'rails_helper'

describe PagesController do

  describe 'Static pages' do
    it 'should include a privacy page' do
      get :show, id: :privacy
      expect(response).to be_ok
    end

    it 'should include a conditions page' do
      get :show, id: :conditions
      expect(response).to be_ok
    end

    it 'should include a terms page' do
      get :show, id: :census_terms
      expect(response).to be_ok
    end
  end

  describe 'Info pages' do
    it 'should include a more_information page' do
      get :show, id: :more_information
      expect(response).to be_ok
    end

    it 'should include a accessibility page' do
      get :show, id: :accessibility
      expect(response).to be_ok
    end
  end

end
