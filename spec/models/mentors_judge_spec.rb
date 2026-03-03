require 'rails_helper'

RSpec.describe MentorsJudge, type: :model do
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: 'Tech') }

  describe 'validations' do
    it 'is valid with a name and year' do
      mj = MentorsJudge.new(year: 2025, name: 'Alice Smith')
      expect(mj).to be_valid
    end

    it 'is not valid without a name' do
      mj = MentorsJudge.new(year: 2025)
      expect(mj).not_to be_valid
    end

    it 'is not valid without a year' do
      mj = MentorsJudge.new(name: 'Alice Smith')
      expect(mj).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to ideathon' do
      mj = MentorsJudge.create!(year: 2025, name: 'Bob')
      expect(mj.ideathon).to eq(ideathon)
    end
  end

  describe 'optional attributes' do
    it 'can have a photo_url, bio, and is_judge flag' do
      mj = MentorsJudge.create!(year: 2025, name: 'Carol', photo_url: 'http://img.com/c.jpg', bio: 'Expert', is_judge: true)
      expect(mj.photo_url).to eq('http://img.com/c.jpg')
      expect(mj.bio).to eq('Expert')
      expect(mj.is_judge).to be true
    end
  end
end
