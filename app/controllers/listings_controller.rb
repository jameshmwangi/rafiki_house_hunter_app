class ListingsController < ApplicationController
  # Public listings: index (search/filter/sort) and show

  def index
    @listings = Listing.published
                       .includes(:location, :property_images)
                       .by_need_type(params[:need_type])
                       .by_location(params[:location_id])
                       .by_country(params[:country])
                       .by_county(params[:county])
                       .by_sub_county(params[:sub_county])
                       .by_area_name(params[:area_name])
                       .by_use_case(params[:use_case])
                       .by_room_layout(params[:room_layout])
                       .price_between(params[:min_price], params[:max_price])
                       .search_by_keyword(params[:keyword])
                       .sorted_by(params[:sort])
                       .page(params[:page])
                       .per(12)

    @locations = Location.order(:area_name)
  end

  def show
    @listing = Listing.includes(:location, :property_images, :property_comments)
                      .find(params[:id])
    authorize! :read, @listing
  end
end
