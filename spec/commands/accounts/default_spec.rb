require "spec_helper"

describe "brightbox accounts" do

  describe "default" do
    let(:output) { FauxIO.new { Brightbox::run(argv) } }
    let(:stdout) { output.stdout }
    let(:stderr) { output.stderr }

    context "" do
      let(:argv) { ["accounts", "default"] }

      it "does not error" do
        expect { output }.to_not raise_error
      end
    end
  end
end