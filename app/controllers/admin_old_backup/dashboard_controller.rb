class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def show
    @users = User.all.order(created_at: :desc)
    @listings = Listing.all.order(created_at: :desc)
    @bookings = ViewingAppointment.all.order(created_at: :desc)

    @total_users = @users.count
    @active_listings = @listings.published.count
    @total_bookings = @bookings.count
    @payments_received = @bookings.where(fee_status: 'paid').sum(:fee_amount)

    # Finance: processed = fee_amount for appointments with successful payments
    @sum_processed = ViewingAppointment
                       .joins(:payment_attempts)
                       .where(payment_attempts: { outcome: 'success' })
                       .sum(:fee_amount)
    # Finance: released = fee_amount for completed appointments
    @sum_released = ViewingAppointment.where(status: 'completed').sum(:fee_amount)
    # Finance: held = processed - released
    @sum_held = @sum_processed - @sum_released
  end
end
