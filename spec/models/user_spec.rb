require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with a unique email and valid role' do
      user = User.new(email: 'test@example.com', role: 'admin')
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = User.new(role: 'admin')
      expect(user).not_to be_valid
    end

    it 'is not valid without a role' do
      user = User.new(email: 'test@example.com', role: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      User.create!(email: 'dup@example.com', role: 'editor')
      user = User.new(email: 'dup@example.com', role: 'admin')
      expect(user).not_to be_valid
    end

    it 'is not valid with an invalid role' do
      user = User.new(email: 'bad@example.com', role: 'superuser')
      expect(user).not_to be_valid
    end
  end

  describe 'role helpers' do
    let(:admin) { User.new(email: 'a@example.com', role: 'admin') }
    let(:editor) { User.new(email: 'e@example.com', role: 'editor') }
    let(:unauth) { User.new(email: 'u@example.com', role: 'unauthorized') }

    it '#admin? returns true for admin' do
      expect(admin).to be_admin
    end

    it '#admin? returns false for non-admin' do
      expect(editor).not_to be_admin
    end

    it '#editor? returns true for editor' do
      expect(editor).to be_editor
    end

    it '#unauthorized? returns true for unauthorized' do
      expect(unauth).to be_unauthorized
    end

    it '#authorized? returns true for admin' do
      expect(admin).to be_authorized
    end

    it '#authorized? returns true for editor' do
      expect(editor).to be_authorized
    end

    it '#authorized? returns false for unauthorized' do
      expect(unauth).not_to be_authorized
    end
  end
end
