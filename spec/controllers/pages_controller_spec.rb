require 'rails_helper'

describe PagesController do

  describe 'Static pages' do
    it 'should include a privacy page' do
      get :privacy
      expect(response).to be_ok
    end

    it 'should include a conditions page' do
      get :conditions
      expect(response).to be_ok
    end

    it 'should include a general terms page' do
      get :general_terms
      expect(response).to be_ok
    end

    it 'should include a terms page' do
      get :census_terms
      expect(response).to be_ok
    end
  end

  describe 'Provisional pages' do
    it 'should include a transparency page' do
      get :transparency
      expect(response).to be_ok
    end

    it 'should include a opendata page' do
      get :opendata
      expect(response).to be_ok
    end
  end

end