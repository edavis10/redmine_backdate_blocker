module RedmineBackdateBlocker
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          validate :check_for_backdated_spent_on
        end
      end

      module ClassMethods
        def backdate_blocker_days
          return nil unless backdated_days_configured?
          Setting.plugin_redmine_backdate_blocker['days'].to_i
        end

        def backdated_days_configured?
          Setting.plugin_redmine_backdate_blocker['days'].present?
        end
      end

      module InstanceMethods
        def check_for_backdated_spent_on
          return unless self.class.backdated_days_configured?
          return if self.class.backdate_blocker_days.days.ago.beginning_of_day <= spent_on.beginning_of_day

          unless allowed_to_backdate?
            errors.add(:spent_on, l(:backdate_blocker_text_must_be_within_days, :days => self.class.backdate_blocker_days))
          end
        end

        def allowed_to_backdate?
          self.class.backdate_blocker_days && User.current.allowed_to?(:backdate_time, project)
        end
      end
    end
  end
end
