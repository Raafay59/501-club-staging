require "rails_helper"

RSpec.describe "Documentation PDFs", type: :request do
     describe "GET /UserDocumentation.pdf" do
          it "serves the user guide PDF from public/" do
               get "/UserDocumentation.pdf"

               expect(response).to have_http_status(:ok)
               expect(response.media_type).to eq("application/pdf")
               expect(response.body.byteslice(0, 4)).to eq("%PDF")
          end
     end

     describe "GET /TechnicalDocumentation.pdf" do
          it "serves the technical documentation PDF from public/" do
               get "/TechnicalDocumentation.pdf"

               expect(response).to have_http_status(:ok)
               expect(response.media_type).to eq("application/pdf")
               expect(response.body.byteslice(0, 4)).to eq("%PDF")
          end
     end
end
