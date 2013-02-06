jruby-jms-rails
===============

Fair Warning: This is my first released gem.  This is a set of libraries which I extracted from an application I'm working
on for my company, and doesn't (yet) include comprehensive testing.

Usage
-----

Firstly, create a job to start your process.  I'm currently using the trinidad worker extension 
<https://github.com/kares/trinidad_worker_extension>.  An example set of Ruby code to start your consumers
is as follows:

    require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))
    require 'jruby/rack/worker/env'
    require 'jruby/rack/worker/logger'
    require 'jms'
    require 'active_model'
    require 'thread'

    require 'jms_consumer'
    JmsConsumer.load_classes
    JmsConsumer.start
    JmsConsumer.await

An example of my `config/trinidad.yml` configuration is as follows.  This ensures Trinidad starts your consumers
in a separate thread so it doesn't block HTTP requests.

    extensions:
      worker:
        jms_consumer:
          jruby.worker.script.path: "lib/jms_consumer/start_worker.rb"
          thread_count: 1

If you don't wish to run this under an application server, you can always start this up manually by running the 
above initialisation script directly.      

Next, you will need to define your processors.  The convention defined is for these to be in `app/processors`,
which is close to as practical for the ActiveMessaging way of doing things.  A simple consumer:

    class TestProcessor < JRuby::JMS::Rails::JmsConsumer
      consumer :test_processor, queue: '/queue/test', workers: 2
      
      def self.on_message(session, message)
        # do something with message
        p message.data
        
        # reply to message
        session.producer(destination: message.jms_reply_to) do |producer|
          producer.send( session.message("Hello, World!") )
        end
      end
    end
    
