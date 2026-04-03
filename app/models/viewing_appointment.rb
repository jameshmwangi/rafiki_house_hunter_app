class ViewingAppointment < ApplicationRecord
  belongs_to :listing
  belongs_to :home_seeker, class_name: "User", foreign_key: :home_seeker_id
  belongs_to :agent,       class_name: "User", foreign_key: :agent_id

  has_many :payment_attempts, dependent: :destroy

  STATUSES     = %w[pending confirmed declined completed].freeze
  FEE_STATUSES = %w[unpaid paid].freeze

  validates :scheduled_at, presence: true
  validates :fee_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :fee_status, presence: true, inclusion: { in: FEE_STATUSES }
end
