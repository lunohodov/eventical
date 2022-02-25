class CharacterEvents
  attr_reader :character

  def initialize(character)
    @character = character
  end

  def pull
    remote_events = Remote.eager(character)

    replace(remote_events) do
      character.update!(last_event_pull_at: Time.current)
    end
  end

  def replace(events, &block)
    Replacement.new(character, events).call(&block)
  end
end
