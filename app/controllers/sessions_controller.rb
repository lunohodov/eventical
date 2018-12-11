class SessionsController < ApplicationController
  def create
    reset_session

    auth_hash = request.env["omniauth.auth"]

    character = Eve::SignIn.new(auth_hash).call

    if character.present?
      session[:character_id] = character.id
      redirect_to calendar_url
    else
      redirect_to login_url
    end
  end

  def destroy
    reset_session
    redirect_to root_url
  end
end
