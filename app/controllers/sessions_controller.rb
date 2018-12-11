class SessionsController < ApplicationController
  def create
    reset_session

    auth_hash = request.env["omniauth.auth"]

    character = Eve::SignIn.new(auth_hash).call

    if character.present?
      session[:character_id] = character.id
      redirect_next
    else
      redirect_to login_url
    end
  end

  def destroy
    reset_session
    redirect_to root_url
  end

  private

  def redirect_next
    redirect_to request.env["omniauth.origin"].presence || calendar_url
  end
end
