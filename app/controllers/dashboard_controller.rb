class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.property_manager?
      @active_listings_count = current_user.listings.published.count
      @booking_requests_count = current_user.agent_appointments.count
      @fees_this_month = current_user.agent_appointments
                                     .where(fee_status: 'paid')
                                     .where('viewing_appointments.created_at >= ?', Time.current.beginning_of_month)
                                     .sum(:fee_amount)
      @avg_rating = current_user.agent_reviews.average(:rating)&.round(1) || 0.0

      @listings = current_user.listings
                              .includes(:location, :property_images)
                              .sorted_by(params[:sort])
                              .page(params[:page])
                              .per(10)
    else
      redirect_to root_path
    end
  end
end
