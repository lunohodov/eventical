class CreateAccessTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :access_tokens do |t|
      t.references :issuer, index: true
      t.references :grantee, polymorphic: true, index: true
      t.string :token, index: true
      t.datetime :expires_at, null: true, default: nil
      t.datetime :revoked_at, null: true, default: nil

      t.timestamps
    end
  end
end
