# coding: utf-8
require 'rails_helper'

feature 'Articles' do

  before do
    Setting['feature.articles'] = true
  end

  after do
    Setting['feature.articles'] = nil
  end

  scenario 'Index' do
    published_articles = [create(:article, :published), create(:article, :published)]
    create(:article, :draft)

    visit articles_path

    expect(page).to have_selector('#articles .article', count: 2)
    published_articles.each do |article|
      within('#articles') do
        expect(page).to have_content article.title
        expect(page).to have_css("a[href='#{article_path(article)}']", text: article.title)
      end
    end
  end

  scenario 'Show' do
    article = create(:article, :published)

    visit article_path(article)

    expect(page).to have_content article.title
    expect(page).to have_content "Article body"
    expect(page).to have_content article.author.name
    expect(page).to have_content I18n.l(article.created_at.to_date)
    expect(page).to have_selector(avatar(article.author.name))
    expect(page.html).to include "<title>#{article.title}</title>"

    within('.social-share-button') do
      expect(page.all('a').count).to be(4) # Twitter, Facebook, Google+, Telegram
    end
  end
end
