class SharingsController < ApplicationController
  def show
    @event_sharing = event_sharing
  end

  def update
    if event_sharing.active?
      event_sharing.deactivate!
    else
      event_sharing.activate!
    end

    redirect_to sharing_url
  end

  private

  def event_sharing
    @event_sharing ||= EventSharing.new(current_character)
  end
end
