require 'spec_helper'

module Pronto
  module Formatter
    describe GitlabFormatter do
      ENV['GITLAB_API_ENDPOINT'] = 'http://example.com/api/v3'
      ENV['GITLAB_API_PRIVATE_TOKEN'] = 'token'

      let(:gitlab_formatter) { GitlabFormatter.new }

      describe '#format' do
        subject { gitlab_formatter.format(messages, repository) }
        let(:messages) { [message, message] }
        let(:repository) { Git::Repository.new('.') }
        let(:message) { Message.new('path/to', line, :warning, 'crucial') }
        let(:line) { double(new_lineno: 1, commit_sha: '123', position: nil) }
        before { line.stub(:commit_line).and_return(line) }

        specify do
          ::Gitlab::Client.any_instance
            .should_receive(:commit_comments)
            .once
            .and_return([])

          ::Gitlab::Client.any_instance
            .should_receive(:create_commit_comment)
            .once

          subject
        end
      end

      describe '#format without duplicates' do
        subject { gitlab_formatter.format(messages, repository) }
        let(:messages) { [message1, message2] }
        let(:repository) { Git::Repository.new('.') }
        let(:message1) { Message.new('path/to1', line1, :warning, 'crucial') }
        let(:message2) { Message.new('path/to2', line2, :warning, 'crucial') }
        let(:line1) { double(new_lineno: 1, commit_sha: '123', position: nil) }
        let(:line2) { double(new_lineno: 2, commit_sha: '123', position: nil) }
        before do
          line1.stub(:commit_line).and_return(line1)
          line2.stub(:commit_line).and_return(line2)
        end

        specify do
          ::Gitlab::Client.any_instance
            .should_receive(:commit_comments)
            .once
            .and_return([])

          ::Gitlab::Client.any_instance
            .should_receive(:create_commit_comment)
            .twice

          subject
        end
      end
    end
  end
end