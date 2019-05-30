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
    style = "border: 0; padding: 0; display: inline-block; vertical-align: top;"

    # rubocop:disable Metrics/LineLength
    button_to("/auth/eve_online_sso", method: :post, remote: false, style: style) do
      image_tag(
        "https://web.ccpgamescdn.com/eveonlineassets/developers/eve-sso-login-black-#{size}.png",
        alt: "Log in with EVE Online",
      )
    end
    # rubocop:enable Metrics/LineLength
  end
end
