require 'rails_helper'

RSpec.describe "judges/new.html.erb", type: :view do
  before(:each) do
    assign(:judge, Judge.new)
  end

  it "renders new judge form" do
    render
    expect(rendered).to have_selector("form")
    expect(rendered).to have_field("judge[judge_name]")
    expect(rendered).to have_field("judge[judge_title]")
    expect(rendered).to have_field("judge[judge_bio]")
    expect(rendered).to have_field("judge[ideathon]")
    expect(rendered).to have_field("judge[judge_photo]")
  end

  it "renders create judge button" do
    render
    expect(rendered).to have_button("Create Judge")
  end

  it "renders back to judges link" do
    render
    expect(rendered).to have_link('Back to Judges', href: judges_path)
  end

  it "renders import judges form" do
    render
    expect(rendered).to have_selector("form[action='#{import_judges_path}']")
    expect(rendered).to have_field("file")
    expect(rendered).to have_button("Import Judges")
  end
end
