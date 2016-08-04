module Resque
  module Failure
    class Notification

      attr_reader :text, :file

      def initialize(failure, level)
        @failure = failure
        @level   = level
        @text = ''
        send(level.to_sym)
      end

      protected

      # Returns the worker & queue linked to the failed job
      #
      def msg_worker
        "*Worker #{@failure.worker} failed processing #{@failure.queue}*"
      end

      # Returns the formatted payload linked to the failed job
      #
      def msg_payload
        ["*Payload:*","```#{format_message(@failure.payload.inspect.split('\n'))}```"]
      end

      # Returns the formatted exception linked to the failed job
      #
      def msg_exception
        ["*Exception:*", "`#{exception}`"]
      end

      # Returns the formatted exception linked to the failed job with backtrace
      # as a slack snippet
      def msg_exception_with_backtrace
        content = ''
        content = exception.backtrace.join('\n') if exception.backtrace #not all exceptions have a backtrace, for instance PruneDeadWorkerDirtyExit
        {
            content: content,
            filetype: 'text',
            filename: 'full_backtrace.txt',
            token: @failure.class.token,
            title: 'Full Exception Backtrace',
            channel: @failure.class.channel
        }
      end

      # Sets the text to be the worker and its payload,
      # the backtrace to be a snippet attachment
      def verbose
        @text = [msg_worker, msg_payload].flatten.join(" \n ")
        @file = msg_exception_with_backtrace
      end

      # Returns the compact text notification
      #
      def compact
        @text = [msg_worker, msg_payload, msg_exception].flatten.join(" \n ")
      end

      # Returns the minimal text notification
      #
      def minimal
        @text = [msg_worker, msg_payload].flatten.join(" \n ")
      end

      def format_message(obj)
        obj
      end

      def exception
        @failure.exception
      end
    end
  end
end

