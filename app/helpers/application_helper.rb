module ApplicationHelper
  def site_name
    "eve-calendars.com"
  end

  def app_version
    ENV["HEROKU_RELEASE_VERSION"]
  end

  def body_class
    qualified_name = controller.controller_path.gsub("/", "-")
    "#{qualified_name} #{qualified_name}-#{controller.action_name}"
  end

  def link_to_eve_online_sso_help(text = "What is this?")
    link_to(
      text,
      "http://community.eveonline.com/news/dev-blogs/eve-online-sso-and-what-you-need-to-know", # rubocop:disable Metrics/LineLength
      target: "_blank",
    )
  end

  def eve_online_sso_button(size = :small)
    size = :small unless %i[small large].include?(size)

    link_to "/auth/eve_online_sso" do
      image_tag(
        "https://web.ccpgamescdn.com/eveonlineassets/developers/eve-sso-login-black-#{size}.png", # rubocop:disable Metrics/LineLength
        alt: "Log in with EVE Online",
      )
    end
  end
end
