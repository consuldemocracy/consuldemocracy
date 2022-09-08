section "Creating header and cards for the homepage" do
  def create_image_attachment(type)
    {
      attachment: Rack::Test::UploadedFile.new("db/dev_seeds/images/#{type}_background.jpg"),
      title: "#{type}_background.jpg",
      user: User.first
    }
  end

  Widget::Card.create!(
    random_locales_attributes(
      %i[title description link_text label].index_with do |attribute|
        -> { I18n.t("seeds.cards.header.#{attribute}") }
      end
    ).merge(
      link_url: "http://consulproject.org/",
      header: true,
      image_attributes: create_image_attachment("header")
    )
  )

  Widget::Card.create!(
    random_locales_attributes(
      %i[title description link_text label].index_with do |attribute|
        -> { I18n.t("seeds.cards.debate.#{attribute}") }
      end
    ).merge(
      link_url: "https://youtu.be/zU_0UN4VajY",
      header: false,
      image_attributes: create_image_attachment("debate")
    )
  )

  Widget::Card.create!(
    random_locales_attributes(
      %i[title description link_text label].index_with do |attribute|
        -> { I18n.t("seeds.cards.proposal.#{attribute}") }
      end
    ).merge(
      link_url: "https://youtu.be/ZHqBpT4uCoM",
      header: false,
      image_attributes: create_image_attachment("proposal")
    )
  )

  Widget::Card.create!(
    random_locales_attributes(
      %i[title description link_text label].index_with do |attribute|
        -> { I18n.t("seeds.cards.budget.#{attribute}") }
      end
    ).merge(
      link_url: "https://youtu.be/igQ8KGZdk9c",
      header: false,
      image_attributes: create_image_attachment("budget")
    )
  )
end
