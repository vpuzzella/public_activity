module PublicActivity
  module ORM
    module ActiveRecordViaSidekiq
      module Trackable
        include PublicActivity::ORM::ActiveRecord::Trackable
      end
    end
  end
end
