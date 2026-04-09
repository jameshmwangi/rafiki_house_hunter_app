require 'rails_helper'

RSpec.describe Listing, type: :model do
  describe 'scopes' do
    let!(:location) { create(:location, county: 'Nairobi', sub_county: 'Westlands', area_name: 'Parklands', country: 'Kenya') }
    let!(:cheap)    { create(:listing, price: 10_000, status: 'published', location: location) }
    let!(:mid)      { create(:listing, price: 30_000, status: 'published', featured: true, location: location) }
    let!(:pricey)   { create(:listing, price: 80_000, status: 'draft', location: location) }

    describe '.published' do
      it 'returns only published listings' do
        expect(Listing.published).to contain_exactly(cheap, mid)
      end
    end

    describe '.featured' do
      it 'returns only featured listings' do
        expect(Listing.featured).to contain_exactly(mid)
      end
    end

    describe '.price_between' do
      it 'filters by min only' do
        expect(Listing.price_between(20_000, nil)).to contain_exactly(mid, pricey)
      end

      it 'filters by max only' do
        expect(Listing.price_between(nil, 30_000)).to contain_exactly(cheap, mid)
      end

      it 'filters by both' do
        expect(Listing.price_between(10_000, 30_000)).to contain_exactly(cheap, mid)
      end

      it 'returns all when both nil' do
        expect(Listing.price_between(nil, nil)).to contain_exactly(cheap, mid, pricey)
      end
    end

    describe '.sorted_by' do
      it 'sorts by price ascending' do
        expect(Listing.sorted_by('price_asc').pluck(:id)).to eq([cheap, mid, pricey].map(&:id))
      end

      it 'sorts by price descending' do
        expect(Listing.sorted_by('price_desc').pluck(:id)).to eq([pricey, mid, cheap].map(&:id))
      end

      it 'defaults to newest' do
        expect(Listing.sorted_by(nil).first).to eq(pricey)
      end
    end

    describe '.search_by_keyword' do
      it 'matches title' do
        cheap.update!(title: 'Cozy Studio Near CBD')
        expect(Listing.search_by_keyword('cozy')).to include(cheap)
      end

      it 'matches location area_name' do
        expect(Listing.search_by_keyword('Parklands')).to contain_exactly(cheap, mid, pricey)
      end

      it 'returns all when keyword blank' do
        expect(Listing.search_by_keyword('').count).to eq(3)
      end
    end

    describe '.by_need_type' do
      it 'filters by need_type' do
        bnb = create(:listing, :bnb, location: location)
        expect(Listing.by_need_type('bnb')).to contain_exactly(bnb)
      end

      it 'returns all when nil' do
        expect(Listing.by_need_type(nil).count).to eq(3)
      end
    end
  end

  describe '#publish!' do
    let(:listing) { create(:listing, :draft) }

    it 'sets status to published and enqueues mailer' do
      expect { listing.publish! }
        .to have_enqueued_job(ActionMailer::MailDeliveryJob)

      expect(listing.reload.status).to eq('published')
    end
  end

  describe '#hide!' do
    let(:listing) { create(:listing, status: 'published') }

    it 'sets status to hidden' do
      listing.hide!
      expect(listing.reload.status).to eq('hidden')
    end
  end
end
