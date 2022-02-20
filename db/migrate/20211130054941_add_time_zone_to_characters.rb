class AddTimeZoneToCharacters < ActiveRecord::Migration[6.1]
  def change
    add_column :characters, :time_zone, :string
  end
end
