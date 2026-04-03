class LocationsController < ApplicationController
  def index
    @locations = Location.order(:county, :area_name)
  end

  def show
    @location = Location.find(params[:id])
    @listings = @location.listings
                         .published
                         .includes(:property_images)
                         .sorted_by(params[:sort])
                         .page(params[:page])
                         .per(12)
  end
end
