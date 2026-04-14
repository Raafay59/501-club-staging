require 'rails_helper'

RSpec.describe Ideathon, type: :model do
  describe 'validations' do
    it 'is valid with a unique integer year' do
      ideathon = Ideathon.new(year: 2025, theme: 'Innovation')
      expect(ideathon).to be_valid
    end

    it 'is not valid without a year' do
      ideathon = Ideathon.new(theme: 'Test')
      expect(ideathon).not_to be_valid
    end

    it 'is not valid with a duplicate year' do
      Ideathon.create!(year: 2024, theme: 'First')
      ideathon = Ideathon.new(year: 2024, theme: 'Second')
      expect(ideathon).not_to be_valid
    end
  end

  describe 'associations' do
    let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

    it 'has many mentors_judges' do
      expect(ideathon).to respond_to(:mentors_judges)
    end

    it 'has many faqs' do
      expect(ideathon).to respond_to(:faqs)
    end

    it 'has many rules' do
      expect(ideathon).to respond_to(:rules)
    end

    it 'has many sponsors_partners' do
      expect(ideathon).to respond_to(:sponsors_partners)
    end

    it 'destroys dependent mentors_judges' do
      MentorsJudge.create!(year: 2025, name: 'Alice')
      expect { ideathon.destroy }.to change(MentorsJudge, :count).by(-1)
    end

    it 'destroys dependent faqs' do
      Faq.create!(year: 2025, question: 'Why?', answer: 'Because.')
      expect { ideathon.destroy }.to change(Faq, :count).by(-1)
    end

    it 'destroys dependent rules' do
      Rule.create!(year: 2025, rule_text: 'Be nice')
      expect { ideathon.destroy }.to change(Rule, :count).by(-1)
    end

    it 'destroys dependent sponsors_partners' do
      SponsorsPartner.create!(year: 2025, name: 'Acme Corp')
      expect { ideathon.destroy }.to change(SponsorsPartner, :count).by(-1)
    end
  end

  describe 'lookup by year' do
    it 'finds by calendar year' do
      ideathon = Ideathon.create!(year: 2023, theme: 'AI')
      expect(Ideathon.find_by!(year: 2023)).to eq(ideathon)
    end
  end
end
