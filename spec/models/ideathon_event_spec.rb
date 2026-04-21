# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdeathonEvent, type: :model do
     describe "associations" do
          it { is_expected.to belong_to(:ideathon_year) }
     end
end
