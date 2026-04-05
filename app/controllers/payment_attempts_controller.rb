class PaymentAttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment

  def new
    authorize! :create, PaymentAttempt
    @listing = @appointment.listing
    @payment_method = params[:payment_method].presence || 'mpesa'
  end

  def create
    authorize! :create, PaymentAttempt

    payment_method = params[:payment_method].presence || 'mpesa'
    simulation     = params[:payment_simulation].presence || 'success'
    outcome        = simulation == 'success' ? 'success' : 'failed'

    @payment = @appointment.payment_attempts.create!(
      payment_method: payment_method,
      outcome: outcome,
      payment_reference: outcome == 'success' ? "WTU-#{SecureRandom.hex(6).upcase}" : nil
    )

    if outcome == 'success'
      @appointment.update!(fee_status: 'paid')
      AppointmentMailer.new_booking(@appointment).deliver_later
      redirect_to listing_path(@appointment.listing), notice: t('payment_attempts.success', reference: @payment.payment_reference)
    else
      redirect_to listing_path(@appointment.listing), alert: t('payment_attempts.failure')
    end
  end

  private

  def set_appointment
    @appointment = current_user.viewing_appointments.find(params[:viewing_appointment_id])
  end
end
