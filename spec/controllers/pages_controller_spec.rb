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

    it 'should include a accessibility page' do
      get :show, id: :accessibility
      expect(response).to be_ok
    end
  end

  describe 'More info pages' do

    it 'should include a more info page' do
      get :show, id: 'more_info/index'
      expect(response).to be_ok
    end

    it 'should include a how_to_use page' do
      get :show, id: 'more_info/how_to_use/index'
      expect(response).to be_ok
    end

    it 'should include a faq page' do
      get :show, id: 'more_info/faq/index'
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
