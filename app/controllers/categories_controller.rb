class CategoriesController < ApplicationController
  skip_authorization_check

  def index
    @categories ||= CategoryDecorator.decorate_collection(Category.all)
  end
end
