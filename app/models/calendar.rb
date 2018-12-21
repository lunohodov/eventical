class Calendar
  Agenda = Struct.new(:date, :events) do
    include Enumerable

    delegate :each, to: :events
    delegate :empty?, to: :events
  end

  attr_reader :character

  def initialize(character)
    @character = character
  end

  def secret_address
    { id: SecureRandom.uuid }
  end

  def empty?
    upcoming_events.empty?
  end

  def agenda_by_date
    agendas = upcoming_events.
      chunk { |e| e.starts_at.to_date }.
      map { |date, events| Agenda.new(date, events) }

    # TODO: Move this to the presentation layer
    unless agendas.empty? || agendas.first.date == Date.current
      agendas.prepend(Agenda.new(Date.current, []))
    end

    agendas
  end

  def upcoming_events
    character.
      events.
      where("starts_at >= ?", Date.current).
      order(starts_at: :asc).
      to_a
  end
end
