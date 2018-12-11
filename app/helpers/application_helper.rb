module ApplicationHelper
  def body_class
    qualified_name = controller.controller_path.gsub("/", "-")
    "#{qualified_name} #{qualified_name}-#{controller.action_name}"
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
