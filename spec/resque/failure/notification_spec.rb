require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe Resque::Failure::Notification do

  Resque::Failure::Slack::LEVELS.each do |level|
    context "level #{level}" do
      it 'returns the wanted format text' do
        notification = described_class.new(failure, level)
        expect(notification.text).to eq expected_text[level]
        expect(notification.file).to eq expected_file[level]
      end

      def expected_text
        {
          verbose: "*Worker worker failed processing queue*\\n*Payload:*\n```\t\"payload\"```",
          compact: "*Worker worker failed processing queue*\\n*Payload:*\n```\t\"payload\"```\\n*Exception:*\n`exception`",
          minimal: "*Worker worker failed processing queue*\\n*Payload:*\n```\t\"payload\"```"
        }
      end

      def expected_file
        {
            verbose: {:content=>"backtrace", :filetype=>"text", :filename=>"full_backtrace.txt", :token=>nil, :title=>"Full Exception Backtrace", :channel=>nil},
            compact: nil,
            minimal: nil
        }
      end
    end
  end

  def failure
    exception = double('exception', to_s: 'exception', backtrace: ['backtrace'])
    Resque::Failure::Slack.new(exception, 'worker', 'queue', 'payload')
  end

end

