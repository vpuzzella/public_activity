module PublicActivity
  module ORM
    module ActiveRecordViaSidekiq
      class Job
        include Sidekiq::Worker
        sidekiq_options PublicActivity.sidekiq_options

        def perform(attrs)
          a = PublicActivity::Activity.new
          attrs.each { |k, v| a.send("#{k}=", v) }
          a.tap(&:save)
        end
      end

      class Adapter < PublicActivity::ORM::ActiveRecord::Adapter
        def self.create_activity(trackable, options)
          Job.perform_async trackable_id: trackable.id,
                            trackable_type: trackable.class.name,
                            owner_id: options[:owner].try(:id),
                            owner_type: options[:owner].try(:class).try(:name),
                            recipient_id: options[:recipient].try(:id),
                            recipient_type: options[:recipient].try(:class).try(:name),
                            key: options[:key],
                            parameters: options[:parameters]
        end
      end
    end
  end
end
