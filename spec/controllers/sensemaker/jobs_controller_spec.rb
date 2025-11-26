require "rails_helper"

describe Sensemaker::JobsController do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:job) do
    create(:sensemaker_job,
           analysable_type: "Debate",
           analysable_id: debate.id,
           user: user,
           finished_at: Time.current,
           persisted_output: Rails.root.join("tmp", "test-report.html").to_s,
           published: true)
  end

  before do
    FileUtils.mkdir_p(File.dirname(job.persisted_output))
    File.write(job.persisted_output, "<html><body>Test Report</body></html>")
  end

  after do
    FileUtils.rm_f(job.persisted_output) if job.persisted_output.present?
  end

  describe "GET #show" do
    context "when job is unpublished" do
      before do
        job.update!(published: false)
      end

      it "returns 302 and redirects to root path" do
        get :show, params: { id: job.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when job exists and has output" do
      it "renders the report view page" do
        get :show, params: { id: job.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when job exists but has no output" do
      before do
        job.update!(persisted_output: nil)
      end

      it "returns 404" do
        get :show, params: { id: job.id }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when job exists but file is missing" do
      before do
        FileUtils.rm_f(job.persisted_output)
      end

      it "returns 404" do
        get :show, params: { id: job.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #serve_report" do
    context "when job is unpublished" do
      before do
        job.update!(published: false)
      end

      it "returns 302 and redirects to root path" do
        get :serve_report, params: { id: job.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when job exists and has output" do
      it "sends the file with correct headers" do
        get :serve_report, params: { id: job.id }

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("text/html")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.body).to include("Test Report")
      end

      it "determines correct content type for HTML files" do
        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("text/html")
      end

      it "determines correct content type for CSV files" do
        job.update!(persisted_output: Rails.root.join("tmp", "test-report.csv").to_s)
        File.write(job.persisted_output, "col1,col2\nval1,val2")

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("text/csv")
      end

      it "determines correct content type for JSON files" do
        job.update!(persisted_output: Rails.root.join("tmp", "test-report.json").to_s)
        File.write(job.persisted_output, '{"test": "data"}')

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("application/json")
      end

      it "determines correct content type for TXT files" do
        job.update!(persisted_output: Rails.root.join("tmp", "test-report.txt").to_s)
        File.write(job.persisted_output, "Plain text content")

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("text/plain")
      end

      it "uses application/octet-stream for unknown file types" do
        job.update!(persisted_output: Rails.root.join("tmp", "test-report.unknown").to_s)
        File.write(job.persisted_output, "Unknown content")

        get :serve_report, params: { id: job.id }

        expect(response.headers["Content-Type"]).to eq("application/octet-stream")
      end
    end

    context "when job does not exist" do
      it "returns 404" do
        get :serve_report, params: { id: 99999 }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when job exists but has no output" do
      before do
        job.update!(persisted_output: nil)
      end

      it "returns 404" do
        get :serve_report, params: { id: job.id }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when job exists but file is missing" do
      before do
        FileUtils.rm_f(job.persisted_output)
      end

      it "returns 404" do
        get :serve_report, params: { id: job.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
