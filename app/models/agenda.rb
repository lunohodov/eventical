class Agenda
  Entry = Struct.new(:date, :events) do
    include Enumerable

    delegate :each, to: :events
    delegate :empty?, to: :events
  end

  include Enumerable

  attr_reader :entries

  delegate :each, to: :entries
  delegate :empty?, to: :entries

  def initialize(events:)
    @entries = create_entries(events).sort_by(&:date)
  end

  def events
    entries.map(&:events).flatten
  end

  private

  def create_entries(events)
    events.
      chunk { |e| e.starts_at.to_date }.
      map { |date, e| Entry.new(date, e) }
  end
end
