class SessionsController < ApplicationController
  def create
    reset_session

    auth_hash = request.env["omniauth.auth"]

    character = Character.where(uid: auth_hash.dig(:info, :character_id)).first

    unless character.present?
      character = Character.create!(
        uid: auth_hash.dig(:info, :character_id),
        name: auth_hash.dig(:info, :name),
        owner_hash: auth_hash.dig(:info, :character_owner_hash),
        token_type: auth_hash.dig(:info, :token_type),
        token: auth_hash.dig(:credentials, :token),
        refresh_token: "...",
        scopes: "...",
        token_expires_at: Time.zone.at(
          auth_hash.dig(:credentials, :expires_at),
        ),
      )
    end

    session[:character_id] = character.id

    redirect_next
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
