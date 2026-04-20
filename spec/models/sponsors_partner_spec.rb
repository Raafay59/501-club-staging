require 'rails_helper'

RSpec.describe SponsorsPartner, type: :model do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  describe 'validations' do
    it 'is valid with name and year' do
      sp = SponsorsPartner.new(year: 2025, name: 'Acme Corp')
      expect(sp).to be_valid
    end

    it 'is not valid without a name' do
      sp = SponsorsPartner.new(year: 2025)
      expect(sp).not_to be_valid
    end

    it 'is not valid without a year' do
      sp = SponsorsPartner.new(name: 'Acme Corp')
      expect(sp).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to ideathon' do
      sp = SponsorsPartner.create!(year: 2025, name: 'BigCo')
      expect(sp.ideathon).to eq(ideathon)
    end
  end

  describe 'optional attributes' do
    it 'can have logo_url, blurb, and is_sponsor flag' do
      sp = SponsorsPartner.create!(year: 2025, name: 'TechCo', logo_url: 'http://logo.png', blurb: 'Great company', is_sponsor: true)
      expect(sp.logo_url).to eq('http://logo.png')
      expect(sp.blurb).to eq('Great company')
      expect(sp.is_sponsor).to be true
    end

    it 'rejects logo URLs with unsupported schemes' do
      sp = SponsorsPartner.new(year: 2025, name: 'BadScheme', logo_url: 'ftp://logo.png')

      expect(sp).not_to be_valid
      expect(sp.errors[:logo_url]).to include('must be a valid HTTP or HTTPS URL')
    end

    it 'rejects malformed logo URLs' do
      sp = SponsorsPartner.new(year: 2025, name: 'Malformed', logo_url: 'http:// bad url')

      expect(sp).not_to be_valid
      expect(sp.errors[:logo_url]).to include('must be a valid URL')
    end
  end
end
