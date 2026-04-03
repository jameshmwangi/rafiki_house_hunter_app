class PaymentAttempt < ApplicationRecord
  belongs_to :viewing_appointment

  PAYMENT_METHODS = %w[mpesa card].freeze
  OUTCOMES        = %w[success failure].freeze

  validates :payment_method, presence: true, inclusion: { in: PAYMENT_METHODS }
  validates :outcome, presence: true, inclusion: { in: OUTCOMES }
end
