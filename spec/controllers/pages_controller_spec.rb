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

    it 'should include a general terms page' do
      get :show, id: :general_terms
      expect(response).to be_ok
    end

    it 'should include a terms page' do
      get :show, id: :census_terms
      expect(response).to be_ok
    end
  end

  describe 'Provisional pages' do
    it 'should include a opendata page' do
      get :show, id: :opendata
      expect(response).to be_ok
    end
  end

  describe 'Info pages' do
    it 'should include a how_it_works page' do
      get :show, id: :how_it_works
      expect(response).to be_ok
    end

    it 'should include a how_to_use page' do
      get :show, id: :how_to_use
      expect(response).to be_ok
    end

    it 'should include a more_information page' do
      get :show, id: :more_information
      expect(response).to be_ok
    end

    it 'should include a participation page' do
      get :show, id: :participation
      expect(response).to be_ok
    end

    it 'should include a accessibility page' do
      get :show, id: :accessibility
      expect(response).to be_ok
    end
  end

  describe 'Not found pages' do
    it 'should return a 404 message' do
      get :show, id: "nonExistentPage"
      expect(response).to be_missing
    end
  end

end
