require 'singleton'

module PublicActivity
  # Class used to initialize configuration object.
  class Config
    include ::Singleton
    attr_accessor :enabled, :table_name

    @@orm = :active_record
    @@sidekiq_options = {}

    def initialize
      # Indicates whether PublicActivity is enabled globally
      @enabled    = true
      @table_name = "activities"
    end

    # Evaluates given block to provide DSL configuration.
    # @example Initializer for Rails
    #   PublicActivity::Config.set do
    #     orm :mongo_mapper
    #     enabled false
    #     table_name "activities"
    #   end
    def self.set &block
      b = Block.new
      b.instance_eval &block
      @@orm = b.orm unless b.orm.nil?
      @@sidekiq_options = b.sidekiq_options unless b.sidekiq_options.nil?
      instance
      instance.instance_variable_set(:@enabled,    b.enabled)     unless  b.enabled.nil?
    end

    # Set the ORM for use by PublicActivity.
    def self.orm(orm = nil)
      @@orm = (orm ? orm.to_sym : false) || @@orm
    end

    # alias for {#orm}
    # @see #orm
    def self.orm=(orm = nil)
      orm(orm)
    end

    # instance version of {Config#orm}
    # @see Config#orm
    def orm(orm=nil)
      self.class.orm(orm)
    end

    # Set the Sidekiq queue for use by PublicActivity.
    def self.sidekiq_options(sidekiq_options = nil)
      @@sidekiq_options = sidekiq_options || @@sidekiq_options
    end

    # alias for {#sidekiq_options}
    # @see #sidekiq_options
    def self.sidekiq_options=(sidekiq_options = nil)
      sidekiq_options(sidekiq_options)
    end

    # instance version of {Config#sidekiq_options}
    # @see Config#sidekiq_options
    def sidekiq_options(sidekiq_options = nil)
      self.class.sidekiq_options(sidekiq_options)
    end

    # Provides simple DSL for the config block.
    class Block
      attr_reader :orm, :enabled, :table_name, :sidekiq_options
      # @see Config#orm
      def orm(orm = nil)
        @orm = (orm ? orm.to_sym : false) || @orm
      end

      # @see Config#sidekiq_options
      def sidekiq_options(sidekiq_options = nil)
        @sidekiq_options = sidekiq_options || @sidekiq_options
      end

      # Decides whether to enable PublicActivity.
      # @param en [Boolean] Enabled?
      def enabled(en = nil)
        @enabled = (en.nil? ? @enabled : en)
      end

      # Sets the table_name
      # for the model
      def table_name(name = nil)
        PublicActivity.config.table_name = name
      end
    end
  end
end
