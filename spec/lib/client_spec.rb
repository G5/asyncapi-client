require "spec_helper"

module Asyncapi
  describe Client do

    describe ".configure" do
      it "allows for a configuration DSL" do
        described_class::CONFIG_ATTRS.each do |attr|
          old_value = described_class.send(attr)
          described_class.configure do |c|
            c.send("#{attr}=", "myvalfor#{attr}")
          end
          expect(described_class.send(attr)).to eq "myvalfor#{attr}"
          described_class.send("#{attr}=", old_value)
        end
      end
    end

    describe ".parent_controller" do
      it "defaults to ActionController::Base if nil" do
        described_class.parent_controller = nil
        expect(described_class.parent_controller).to eq ActionController::Base
      end
    end

    describe ".expiry_threshold" do
      it "defaults to 4 days" do
        expect(described_class.expiry_threshold).to eq 4.days
      end
    end

    describe ".succeeded_job_deletion_threshold" do
      it "defaults to 2 minutes" do
        expect(described_class.succeeded_job_deletion_threshold).to eq 2.minutes
      end
    end

    describe ".clean_job_cron" do
      it "defaults to '0 0 * * *'" do
        expect(described_class.clean_job_cron).to eq "0 0 * * *"
      end
    end

  end
end
