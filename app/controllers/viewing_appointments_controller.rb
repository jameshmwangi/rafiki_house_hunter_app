class ViewingAppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing

  def new
    @appointment = @listing.viewing_appointments.build(
      fee_amount: @listing.viewing_fee
    )
    authorize! :create, @appointment
  end

  def create
    @appointment = @listing.viewing_appointments.build(appointment_params)
    @appointment.home_seeker = current_user
    @appointment.agent = @listing.user
    @appointment.fee_amount = @listing.viewing_fee
    authorize! :create, @appointment

    if @appointment.save
      AppointmentMailer.new_booking(@appointment).deliver_later
      redirect_to listing_path(@listing), notice: t('viewing_appointments.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_listing
    @listing = Listing.published.find(params[:listing_id])
  end

  def appointment_params
    params.require(:viewing_appointment).permit(:scheduled_at)
  end
end
