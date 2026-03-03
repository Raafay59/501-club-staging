require 'rails_helper'

RSpec.describe Faq, type: :model do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  describe 'validations' do
    it 'is valid with question, answer, and year' do
      faq = Faq.new(year: 2025, question: 'What?', answer: 'This.')
      expect(faq).to be_valid
    end

    it 'is not valid without a question' do
      faq = Faq.new(year: 2025, answer: 'This.')
      expect(faq).not_to be_valid
    end

    it 'is not valid without an answer' do
      faq = Faq.new(year: 2025, question: 'What?')
      expect(faq).not_to be_valid
    end

    it 'is not valid without a year' do
      faq = Faq.new(question: 'What?', answer: 'This.')
      expect(faq).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to ideathon' do
      faq = Faq.create!(year: 2025, question: 'Why?', answer: 'Because.')
      expect(faq.ideathon).to eq(ideathon)
    end
  end
end
