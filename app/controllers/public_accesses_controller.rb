class PublicAccessesController < ApplicationController
  def show
    @event_sharing = event_sharing
  end

  def update
    event_sharing.toggle!

    redirect_to public_access_url
  end

  private

  def event_sharing
    @event_sharing ||= EventSharing.new(current_character)
  end
end
