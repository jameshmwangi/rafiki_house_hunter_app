module Dashboard
  class ListingsController < BaseController
    before_action :set_listing, only: [:edit, :update, :destroy, :publish, :hide]

    def index
      @listings = current_user.listings
                              .includes(:location, :property_images)
                              .sorted_by(params[:sort])
                              .page(params[:page])
                              .per(10)
    end

    def new
      @listing = current_user.listings.build
      @locations = Location.order(:area_name)
    end

    def create
      @listing = current_user.listings.build(listing_params)

      ActiveRecord::Base.transaction do
        current_user.upgrade_to_agent! if current_user.home_seeker?
        @listing.save!
      end

      redirect_to dashboard_listings_path, notice: t('listings.created')
    rescue ActiveRecord::RecordInvalid
      @locations = Location.order(:area_name)
      render :new, status: :unprocessable_entity
    end

    def edit
      authorize! :update, @listing
      @locations = Location.order(:area_name)
    end

    def update
      authorize! :update, @listing
      if @listing.update(listing_params)
        redirect_to dashboard_listings_path, notice: t('listings.updated')
      else
        @locations = Location.order(:area_name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @listing
      @listing.destroy
      redirect_to dashboard_listings_path, notice: t('listings.destroyed')
    end

    def publish
      authorize! :publish, @listing
      @listing.update!(status: 'published')
      ListingMailer.listing_published(@listing).deliver_later
      redirect_to dashboard_listings_path, notice: t('listings.published')
    end

    def hide
      authorize! :hide, @listing
      @listing.update!(status: 'hidden')
      redirect_to dashboard_listings_path, notice: t('listings.hidden')
    end

    private

    def set_listing
      @listing = current_user.listings.find(params[:id])
    end

    def listing_params
      params.require(:listing).permit(
        :title, :description, :need_type, :use_case, :room_layout,
        :price, :price_period, :building_name, :location_id,
        :bathrooms, :viewing_fee, :status
      )
    end
  end
end
