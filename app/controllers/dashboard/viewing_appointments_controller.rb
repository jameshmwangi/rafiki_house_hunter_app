module Dashboard
  class ViewingAppointmentsController < BaseController
    before_action :set_appointment, only: [:update]

    def index
      @appointments = current_user.agent_appointments
                                  .includes(:listing, :home_seeker, payment_attempts: [])
                                  .order(created_at: :desc)
      @appointments = @appointments.where(status: params[:status]) if params[:status].present?
      @appointments = @appointments.page(params[:page]).per(10)

      @counts = {
        all: current_user.agent_appointments.count,
        pending: current_user.agent_appointments.where(status: 'pending').count,
        confirmed: current_user.agent_appointments.where(status: 'confirmed').count,
        completed: current_user.agent_appointments.where(status: 'completed').count
      }
    end

    def update
      authorize! params[:status_action].to_sym, @appointment

      case params[:status_action]
      when 'confirm'
        @appointment.update!(status: 'confirmed')
        AppointmentMailer.booking_confirmed(@appointment).deliver_later
        redirect_to dashboard_appointments_path, notice: t('dashboard.booking_confirmed')
      when 'decline'
        @appointment.update!(status: 'declined')
        AppointmentMailer.booking_declined(@appointment).deliver_later
        redirect_to dashboard_appointments_path, notice: t('dashboard.booking_declined')
      when 'complete'
        @appointment.update!(status: 'completed')
        AppointmentMailer.booking_completed(@appointment).deliver_later
        redirect_to dashboard_appointments_path, notice: t('dashboard.booking_completed')
      else
        redirect_to dashboard_appointments_path, alert: t('errors.not_authorized')
      end
    end

    private

    def set_appointment
      @appointment = current_user.agent_appointments.find(params[:id])
    end
  end
end
