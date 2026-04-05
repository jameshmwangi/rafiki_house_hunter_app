module RailsAdmin
  class DashboardController < RailsAdmin::MainController
    def index
      # ── Stat cards (top row) ───────────────────────────────────
      @stats = {
        total_users:       User.count,
        active_listings:   Listing.published.count,
        total_bookings:    ViewingAppointment.count,
        payments_received: PaymentAttempt
                             .successful
                             .joins(:viewing_appointment)
                             .sum('viewing_appointments.fee_amount')
      }

      # ── Finance summary (bottom section) ──────────────────────
      @finance = {}

      @finance[:total_processed] = PaymentAttempt
        .successful
        .joins(:viewing_appointment)
        .sum('viewing_appointments.fee_amount')

      # Total Released = viewings that are COMPLETED
      @finance[:total_released] = ViewingAppointment
        .status_completed
        .joins(:payment_attempts)
        .where(payment_attempts: { outcome: 'success' })
        .sum(:fee_amount)

      # Held in Escrow = viewings CONFIRMED or AWAITING_CONFIRMATION
      @finance[:held_in_escrow] = ViewingAppointment
        .where(status: %w[awaiting_confirmation confirmed])
        .joins(:payment_attempts)
        .where(payment_attempts: { outcome: 'success' })
        .sum(:fee_amount)

      # ── Preview tables (5 records each) ───────────────────────
      @recent_users    = User.order(created_at: :desc).limit(5)
      @recent_listings = Listing
                           .includes(:user, :location)
                           .order(created_at: :desc)
                           .limit(5)
    end
  end
end
