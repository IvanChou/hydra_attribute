require 'hydra_attribute/configuration'

module HydraAttribute
  SUPPORT_TYPES = [:string, :text, :integer, :float, :datetime, :boolean]

  class << self
    def config
      @config ||= ::HydraAttribute::Configuration.new
    end

    def setup
      yield config
    end
  end

end

require 'hydra_attribute/version'
require 'hydra_attribute/active_record'
require 'hydra_attribute/active_record/relation'
require 'hydra_attribute/association'
require 'hydra_attribute/attribute'
require 'hydra_attribute/builder'
require 'hydra_attribute/migration'
require 'hydra_attribute/scoped'

require 'hydra_attribute/railtie' if defined?(Rails)
