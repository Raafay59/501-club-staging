# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdeathonYear, type: :model do
     describe "associations" do
          it { is_expected.to have_many(:teams) }
          it { is_expected.to have_many(:registered_attendees) }
     end
end
