module JMS
  module Rails
    class JmsConsumer
      cattr_accessor :consumers

      def self.consumer(*args)
        options = args.extract_options!
        
        options[:workers] ||= 1
        unless (options[:workers] > 0 && options[:workers] <= 10)
          raise "Invalid number of consumers specified: #{options[:workers].to_s}"
        end

        if options[:topic] && options[:queue]
          raise "You cannot listen to both a queue and a topic."
        end

        class_name = caller[0][/`([^']*)'/, 1]

        Rails.logger.info "Loading consumer for #{options[:queue] ? 'queue' : 'topic'} <#{options[:queue] ? options[:queue] : options[:topic]}>, class=<#{class_name}>"
        self.consumers ||= []

        options[:workers].times do
          self.consumers << Thread.new do |thread|
            JMS::Connection.session(APP_CONFIG) do |session|
              if options[:queue]
                session.consume(queue_name: options[:queue], timeout: -1) do |message|
                  Rails.logger.info "Consumed message for queue <#{options[:queue]}>"
                  Rails.logger.debug "Message content: #{message.data}"
                  class_name.constantize.on_message(session, message)
                end

              else
                session.consume(topic_name: options[:topic], timeout: -1) do |message|
                  Rails.logger.info "Consumed message for topic <#{options[:topic]}>"
                  Rails.logger.debug "Message content: #{message.data}"
                  class_name.constantize.on_message(session, message)
                end
              end
            end
          end
        end
      end

      def self.load_classes
        Dir[Rails.root.join('app', 'processors', '*.rb')].each { |file| require file }
      end

      def self.await
        self.consumers ||= []
        self.consumers.map(&:join)
      end
    end
  end
end
