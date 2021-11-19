module ApplicationHelper
  def site_name
    "eve-calendars.com"
  end

  def app_version
    Eventical.release_version
  end

  def body_class
    qualified_name = controller.controller_path.tr("/", "-")
    "#{qualified_name} #{qualified_name}-#{controller.action_name}"
  end

  def link_to_eve_online_sso_help(text = "What is this?")
    link_to(
      text,
      "http://community.eveonline.com/news/dev-blogs/eve-online-sso-and-what-you-need-to-know", # rubocop:disable Layout/LineLength
      target: "_blank",
      rel: "noopener help"
    )
  end

  def eve_online_sso_button(size = :small)
    size = :small unless %i[small large].include?(size)
    style = "border: 0; padding: 0; display: inline-block; vertical-align: top;"

    # rubocop:disable Layout/LineLength
    button_to("/auth/eve_online_sso", method: :post, remote: false, style: style) do
      image_tag(
        "https://web.ccpgamescdn.com/eveonlineassets/developers/eve-sso-login-white-#{size}.png",
        alt: "Log in with EVE Online"
      )
    end
    # rubocop:enable Layout/LineLength
  end
end
