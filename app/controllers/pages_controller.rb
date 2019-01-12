class PagesController < ApplicationController
  def index; end

  def about; end

  protected

  def site_name
    "eventical"
  end
  helper_method :site_name
end
