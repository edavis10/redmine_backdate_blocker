require 'redmine'

Redmine::Plugin.register :redmine_backdate_blocker do
  name 'Backdate Blocker'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/backdate-blocker'
  author_url 'http://www.littlestreamsoftware.com'
  description 'A Redmine plugin that prevents users from clocking time to past dates.'
  version '0.1.0'

  requires_redmine :version_or_higher => '0.9.0'

  settings(:partial => 'settings/backdate_blocker_settings',
           :default => {
             'days' => '3'
           })

  project_module :time_tracking do
    permission :backdate_time, {}
  end
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_backdate_blocker do

  require_dependency 'time_entry'
  TimeEntry.send(:include, RedmineBackdateBlocker::Patches::TimeEntryPatch)
end
