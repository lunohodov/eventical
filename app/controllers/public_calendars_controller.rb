class PublicCalendarsController < ApplicationController
  def show
    @event_sharing = event_sharing
  end

  def update
    event_sharing.toggle!

    redirect_to public_calendar_path
  end

  private

  def event_sharing
    @event_sharing ||= EventSharing.new(current_character)
  end
end
