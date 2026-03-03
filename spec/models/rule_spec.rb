require 'rails_helper'

RSpec.describe Rule, type: :model do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  describe 'validations' do
    it 'is valid with rule_text and year' do
      rule = Rule.new(year: 2025, rule_text: 'Be respectful')
      expect(rule).to be_valid
    end

    it 'is not valid without rule_text' do
      rule = Rule.new(year: 2025)
      expect(rule).not_to be_valid
    end

    it 'is not valid without a year' do
      rule = Rule.new(rule_text: 'Be respectful')
      expect(rule).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to ideathon' do
      rule = Rule.create!(year: 2025, rule_text: 'No plagiarism')
      expect(rule.ideathon).to eq(ideathon)
    end
  end
end
