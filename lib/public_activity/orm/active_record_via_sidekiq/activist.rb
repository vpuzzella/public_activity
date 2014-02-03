module PublicActivity
  module ORM
    module ActiveRecordViaSidekiq
      module Activist
        include PublicActivity::ORM::ActiveRecord::Activist
      end
    end
  end
end
