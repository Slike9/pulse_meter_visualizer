module PulseMeter
  module Visualize
    module DSL 
      class Sensor < Base

        self.data_class = PulseMeter::Visualize::Sensor

        def initialize(name)
          super()
          self.name(name)
        end

        string_setter :color
        string_setter :name
      end
    end
  end
end


