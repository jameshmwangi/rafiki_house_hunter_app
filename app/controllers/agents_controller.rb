class AgentsController < ApplicationController
  def show
    @agent = User.where(role: %w[agent landlord admin]).find(params[:id])
    @listings = @agent.listings.published
                      .includes(:location, :property_images)
                      .page(params[:page])
                      .per(6)
    @reviews = @agent.agent_reviews.includes(:author).order(created_at: :desc)
    @avg_rating = @agent.agent_reviews.average(:rating)&.round(1) || 0.0
    @review_count = @agent.agent_reviews.count
  end
end
