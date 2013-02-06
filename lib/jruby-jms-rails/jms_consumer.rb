
module JMS
  module Rails
    class JmsConsumer
      cattr_accessor :consumers
      cattr_accessor :consumer_class

      def self.consumer(*args)
        options = { :workers => 1 }.merge!(args.extract_options!)

        unless options[:workers] > 0 && options[:workers] <= 10
          raise "Invalid number of workers specified: #{workers.to_s}"
        end

        class_name = caller[0][/`([^']*)'/, 1]

        logger.info "Consumer class defined class=<#{class_name}>, queue=<#{options[:queue]}, workers=<#{options[:workers]}"
        self.consumer_class ||= []
        self.consumer_class << {
          :class_name   => class_name.constantize,
          :queue_name   => options[:queue],
          :workers    => options[:workers]
        }
      end

      def self.load_classes
        Dir[Rails.root.join('app', 'processors', '*.rb')].each {|file| require file }
      end

      def self.start_thread(*args)
        options = args.extract_options!

        logger.info "Starting consumer for queue=<#{options[:queue_name]}>, class=<#{self.name}>"
        JMS::Connection.session(APP_CONFIG) do |session|
          session.consume(queue_name: options[:queue_name], timeout: -1) do |message|
            begin
              logger.debug "Consumed message for queue=<#{options[:queue_name]}>, class=<#{self.name}>, data=<#{message.data.inspect}>"
              self.on_message(session, message)
            rescue => e
              logger.error "Exception encountered in message queue=<#{options[:queue_name]}>, "+
                "class=<#{options[:class_name]}>, message=<#{message.data.inspect}>, exception=<#{e.message}>, backtrace=<#{e.backtrace}>"
            end
          end
        end

      end

      def self.start

        self.consumers ||= []
        self.consumer_class.each do |cc|
          cc[:workers].times do |iter|
            self.consumers << Thread.new do |thread|
              cc[:class_name].start_thread queue_name: cc[:queue_name]
            end
          end
        end

      end

      def self.await
        self.consumers ||= []
        self.consumers.map(&:join)
      end

      def self.logger
        if !Rails.logger.nil? 
          @logger = Rails.logger
        elsif !JRuby::Rack::Worker.logger.nil?
          @logger = JRuby::Rack::Worker.logger
        else
          @logger = Logger.new(STDOUT)
        end
        @logger
      end

      def self.logger=(obj)
        @logger = obj
      end
      
    end
  end
end
