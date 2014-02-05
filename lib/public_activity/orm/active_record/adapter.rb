module PublicActivity
  module ORM
    # Support for ActiveRecord for PublicActivity. Used by default and supported
    # officialy.
    module ActiveRecord
      # Provides ActiveRecord specific, database-related routines for use by
      # PublicActivity.
      class Adapter
        # Creates the activity on `trackable` with `options`
        def self.create_activity(trackable, options)
          unless (sidekiq_options = options.delete(:sidekiq)) && defined?(Sidekiq::Worker)
            return trackable.activities.create(options)
          end

          Worker.client_push(
            sidekiq_options.merge(
              'class' =>  Worker,
              'args'  =>  [{
                trackable_id:   trackable.id,
                trackable_type: trackable.class.name,
                owner_id:       options[:owner].try(:id),
                owner_type:     options[:owner].try(:class).try(:name),
                recipient_id:   options[:recipient].try(:id),
                recipient_type: options[:recipient].try(:class).try(:name),
                key:            options[:key],
                parameters:     options[:parameters],
                occurred_at:    options[:occurred_at],
              }]
            )
          )
        end
      end

      if defined?(Sidekiq::Worker)
        class Worker
          include Sidekiq::Worker

          def perform(attrs)
            a = PublicActivity::Activity.new
            attrs.each { |k, v| a.send("#{k}=", v) }
            a.tap(&:save)
          end
        end
      end
    end
  end
end
