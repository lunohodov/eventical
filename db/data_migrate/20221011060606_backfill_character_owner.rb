ActiveRecord::Base.connection.execute(<<-SQL)
  UPDATE access_tokens
    SET
      character_owner_hash = characters.owner_hash
    FROM
      characters
    WHERE
      access_tokens.issuer_id = characters.id
      AND access_tokens.character_owner_hash IS NULL
      AND characters.owner_hash IS NOT NULL;

  UPDATE events
    SET
      character_owner_hash = characters.owner_hash
    FROM
      characters
    WHERE
      events.character_id = characters.id
      AND events.character_owner_hash IS NULL
      AND characters.owner_hash IS NOT NULL;
SQL
