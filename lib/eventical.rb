# frozen_string_literal: true

module Eventical
  def self.release_version
    # Set by Dyno Metadata. See https://devcenter.heroku.com/articles/dyno-metadata
    ENV["HEROKU_RELEASE_VERSION"]
  end
end
