module RedmineBackdateBlocker
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          validate :backdated_time
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def backdated_time
          if Setting.plugin_redmine_backdate_blocker['days'] && Setting.plugin_redmine_backdate_blocker['days'].present?
            backdated_days = Setting.plugin_redmine_backdate_blocker['days'].to_i

            return true if backdated_days.to_i.days.ago.beginning_of_day <= spent_on.beginning_of_day

            unless User.current.allowed_to?(:backdate_time, project)
              errors.add(:spent_on, l(:backdate_blocker_text_must_be_within_days, :days => backdated_days))
            end
            
          else
            true
          end
        end
      end
    end
  end
end
