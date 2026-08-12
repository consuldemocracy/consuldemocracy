# frozen_string_literal: true

class Sensemaker::AboutComponent < ApplicationComponent
  def title
    t("sensemaker.job_index.contextual_info.title")
  end

  def how_created
    t("sensemaker.job_index.contextual_info.how_created")
  end

  def what_to_expect
    t("sensemaker.job_index.contextual_info.what_to_expect")
  end

  def more_info
    link_text = t("sensemaker.job_index.contextual_info.more_info_link")
    link = link_to(link_text,
                   "https://jigsaw-code.github.io/sensemaking-tools/",
                   target: "_blank",
                   rel: "noopener")
    t("sensemaker.job_index.contextual_info.more_info", link: link).html_safe
  end
end
