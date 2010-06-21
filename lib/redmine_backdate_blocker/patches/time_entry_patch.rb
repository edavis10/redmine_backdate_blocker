module RedmineBackdateBlocker
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          validate :check_for_backdated_spent_on
          before_destroy :check_for_backdated_spent_on
        end
      end

      module ClassMethods
        def backdate_blocker_days
          return nil unless backdated_days_configured?
          Setting.plugin_redmine_backdate_blocker['days'].to_i
        end

        def backdate_blocker_days_ago
          return nil if backdate_blocker_days.nil?
          backdate_blocker_days.days.ago
        end

        def backdated_days_configured?
          Setting.plugin_redmine_backdate_blocker['days'].present?
        end
      end

      module InstanceMethods
        def check_for_backdated_spent_on
          return true unless self.class.backdated_days_configured?
          return true unless backdated?

          unless allowed_to_backdate?
            errors.add_to_base(l(:backdate_blocker_text_must_be_prior, :date => format_date(self.class.backdate_blocker_days_ago), :extra_message => ''))
          end

          errors.length == 0
        end

        def allowed_to_backdate?
          self.class.backdate_blocker_days && User.current.allowed_to?(:backdate_time, project)
        end

        def backdated?
          spent_on.beginning_of_day < self.class.backdate_blocker_days.days.ago.beginning_of_day
        end
      end
    end
  end
end
