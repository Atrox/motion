# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

require "motion"

module Motion
  module Component
    module Motions
      extend ActiveSupport::Concern

      included do
        class_attribute :_motion_handlers,
          instance_reader: false,
          instance_writer: false,
          instance_predicate: false,
          default: {}.freeze
      end

      class_methods do
        def map_motion(motion, handler = motion)
          self._motion_handlers =
            _motion_handlers.merge(motion.to_s => handler.to_sym).freeze
        end
      end

      def motions
        _motion_handlers.keys
      end

      def process_motion(motion, event = nil)
        unless (handler = _motion_handlers[motion])
          raise MotionNotMapped.new(self, motion)
        end

        if method(handler).arity.zero?
          send(handler)
        else
          send(handler, event)
        end
      end

      def map_motion(motion, handler = motion)
        self._motion_handlers =
          _motion_handlers.merge(motion.to_s => handler.to_sym).freeze
      end

      private

      attr_writer :_motion_handlers

      def _motion_handlers
        return @_motion_handlers if defined?(@_motion_handlers)

        self.class._motion_handlers
      end
    end
  end
end
