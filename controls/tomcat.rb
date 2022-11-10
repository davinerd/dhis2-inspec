# Based on Tomcat9 CIS Benchmark 1.1.0
tomcat_service = input('tomcat_service', value: 'enable')
tomcat_user = input('tomcat_user', value: 'tomcat')
tomcat_group = input('tomcat_group', value: 'tomcat')
catalina_home = input('catalina_home', value: '/usr/share/tomcat9')
tomcat_conf = input('tomcat_conf', value: '/etc/tomcat9')
tomcat_libs = input('tomcat_libs', value: '/var/lib/tomcat9')
tomcat_logs = input('tomcat_logs', value: '/var/log/tomcat9')
tomcat_cache = input('tomcat_cache', value: '/var/cache/tomcat9')
tomcat_log_filehandler = input('logging_filehandler', value: 'AsyncFileHandler')

control 'tomcat.dedicated_user' do
  impact 1.0

  title 'The application server must run under a dedicated (operating-system) account that only has the permissions required for operation.'
  describe user(tomcat_user) do
    it { should exist }
  end
  describe group(tomcat_group) do
    it { should exist }
  end
end

control 'tomcat.dedicated_service' do
  impact 1.0

  title 'If not containerized, the application service must be installed properly.'
  describe service('tomcat9') do
    before do
      skip if tomcat_service == 'disable'
    end
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe processes('tomcat9') do
    before do
      skip if tomcat_service == 'disable'
    end
    its('users') { should eq [tomcat_user] }
  end
end

control 'tomcat.shutdownport' do
  impact 1.0

  tag cis_id: 3.2
  tag cis_level: 2

  title 'If the shutdown port is not needed, it must be deactivated.'
  describe file(tomcat_conf + '/server.xml') do
    its('content') { should match '<Server port="-1"' }
  end
end

control 'tomcat.autodeploy' do
  tag cis_id: 9.2
  tag cis_level: 2

  title 'Automatic deployment of applications must be disabled.'
  describe file(tomcat_conf + '/server.xml') do
    its('content') { should_not match 'autoDeploy="true"' }
    its('content') { should_not match 'deployXML="true"' }
  end
end

# This is currently needed by DHIS2
#control 'tomcat.deploy on startup' do
#  tag cis_id: 9.3
#  tag cis_level: 2
#
#  title 'Disable deploy on startup of applications.'
#  describe file(tomcat_conf + '/server.xml') do
#    its('content') { should match 'deployOnStartup="false"' }
#  end
#end

control 'tomcat.sensitive_info' do
  impact 1.0

  tag cis_id: "2.1/2.2/2.3/2.4/2.6"
  tag cis_level: 2

  title 'Sensitive information must not be contained in files, outputs or messages that are by unauthorized users accessible.'
  describe file(tomcat_conf + '/server.xml') do
    its('content') { should_not match 'xpoweredBy="true"' }
    its('content') { should_not match 'allowTrace="true"' }
    its('content') { should_not match 'server=" "' }
  end
end

control 'tomcat.sample_apps' do
  impact 1.0

  tag cis_id: 1.1
  tag cis_level: 2

  title 'Sample applications and unnecessary standard tools must be deleted.'
  describe directory(tomcat_libs + '/webapps/js-examples') do
    it { should_not exist }
  end
  describe directory(tomcat_libs + '/webapps/servlet-example') do
    it { should_not exist }
  end
  describe directory(tomcat_libs + '/webapps/tomcat-docs') do
    it { should_not exist }
  end
  describe directory(tomcat_libs + '/webapps/balancer') do
    it { should_not exist }
  end
  describe directory(tomcat_libs + '/webapps/ROOT/admin') do
    it { should_not exist }
  end
  describe directory(tomcat_libs + '/webapps/examples') do
    it { should_not exist }
  end
  describe directory(tomcat_libs + '/server/webapps/host-manager') do
    it { should_not exist }
  end
end

control 'tomcat.manager_app' do
  impact 1.0
  tag cis_id: "10.3/10.4"
  tag cis_level: 2

  title 'If the "manager" application is used, this must be protected against unauthorized use.'

  if File.directory?(tomcat_libs + '/webapps/manager')
    describe file(tomcat_conf + '/server.xml') do
      its('owner') { should eq tomcat_user }
      its('group') { should eq tomcat_group }
      its('mode') { should cmp '0640' }
      its('content') { should match 'org.apache.catalina.users.MemoryUserDatabaseFactory' }
    end
    describe file(tomcat_conf + '/tomcat-users.xml') do
      its('owner') { should eq tomcat_user }
      its('group') { should eq tomcat_group }
      its('mode') { should cmp '0640' }
      its('content') { should match '<user username=".*"\s+password=".*"\s+roles=".*manager-gui.*"(\s+)?/>' }
    end
    describe file(tomcat_libs + '/webapps/manager/WEB-INF/web.xml') do
      its('owner') { should eq tomcat_user }
      its('group') { should eq tomcat_group }
      its('mode') { should cmp '0640' }
      its('content') { should match '<transport-guarantee>CONFIDENTIAL</transport-guarantee>' }
    end
  end
end

control 'tomcat.logging' do
  impact 1.0

  tag cis_id: 7.2
  tag cis_level: 1

  title 'Specify file handler in logging.properties file'
  desc 'Access to the application server must be logged.'

  describe file(tomcat_conf + '/logging.properties') do
    it { should exist }
    its('content') { should match '.handlers = 1catalina.org.apache.juli.' + tomcat_log_filehandler + ', java.util.logging.ConsoleHandler' }
    its('content') { should match '1catalina.org.apache.juli.' + tomcat_log_filehandler + '.level = FINE' }
    its('content') { should match '2localhost.org.apache.juli.' + tomcat_log_filehandler + '.level = FINE' }
    its('content') { should match 'java.util.logging.ConsoleHandler.level = FINE' }
    its('content') { should match '.level = INFO' }
  end
end

# We use log4j2 for this so disabling
#control 'tomcat.logging_valve' do
#  impact 1.0
#
#  tag cis_id: 7.3
#  tag cis_level: 2
#
#  title 'Ensure className valve is set correctly'
#  desc 'Access to the application server must be logged.'
#
#  describe file(tomcat_conf + '/server.xml') do
#    it { should exist }
#    its('content') { should match 'org.apache.catalina.valves.AccessLogValve' }
#  end
#end

control 'tomcat.files_directories' do
  impact 1.0

  tag cis_id: "4.x"
  tag cis_level: 1

  title 'Check for existence and correct permissions of tomcat directories'
  describe directory(catalina_home) do
    it { should be_directory }
    its('owner') { should eq tomcat_user }
    its('group') { should eq tomcat_group }
    its('mode') { should cmp '0750' }
  end
  ::Dir.glob(catalina_home + '/bin/*.sh').each do |fname|
    describe file(fname) do
      it { should be_file }
      its('owner') { should eq tomcat_user }
      its('group') { should eq tomcat_group }
      its('mode') { should cmp '0750' }
    end
  end
  dirfiles = ::Dir.glob(tomcat_conf + '/*').reject do |path|
    File.directory?(path)
  end
  dirfiles.each do |fname|
    describe file(fname) do
      it { should be_file }
      its('owner') { should eq tomcat_user }
      its('group') { should eq tomcat_group }
      if fname.end_with?("/web.xml")
	      its('mode') { should cmp '0400'}
      else
       its('mode') { should cmp '0600' }
      end
    end
  end
  describe directory(tomcat_conf) do
    it { should be_directory }
    its('owner') { should eq tomcat_user }
    its('group') { should eq tomcat_group }
    its('mode') { should cmp '0750' }
  end
  describe directory(tomcat_logs) do
    it { should be_directory }
    its('mode') { should cmp '02770' }
  end
  dirfiles = ::Dir.glob(tomcat_logs + '/*').reject do |path|
    File.directory?(path)
  end
  dirfiles.each do |fname|
    describe file(fname) do
      it { should be_file }
      its('mode') { should cmp '0640' }
    end
  end
  describe directory(tomcat_libs) do
    it { should be_directory }
    its('owner') { should eq tomcat_user }
    its('group') { should eq tomcat_group }
    its('mode') { should cmp '0750' }
  end
  describe directory(tomcat_cache) do
    it { should be_directory }
    its('owner') { should eq tomcat_user }
    its('group') { should eq tomcat_group }
    its('mode') { should cmp '0750' }
 end
end

control 'tomcat.unstable_realm' do
  impact 1.0
  title 'Reals not ready for production use'

  tag cis_id: 5.1
  tag cis_level: 2

  describe file(tomcat_conf + '/server.xml') do
    its('content') { should_not match 'org.apache.catalina.realm.MemoryRealm' }
    its('content') { should_not match 'org.apache.catalina.realm.JDBCRealm' }
    its('content') { should_not match 'org.apache.catalina.realm.UserDatabaseRealm' }
    its('content') { should_not match 'org.apache.catalina.realm.JAASRealm' }
  end
end

control 'tomcat.lock_out_realm' do
  impact 1.0
  title 'Use the LockOutRealm to prevent attempts to guess user passwords via a brute-force attack'

  tag cis_id: 5.2
  tag cis_level: 2

  describe file(tomcat_conf + '/server.xml') do
    its('content') { should match '<Realm\s+className="org.apache.catalina.realm.LockOutRealm"(\s+)?>' }
  end
end

control 'tomcat.https_scheme' do
  impact 1.0
  title 'Ensure scheme is set accurately'

  tag cis_id: 6.3
  tag cis_level: 1

  describe file(tomcat_conf + '/server.xml') do
    its('content') { should match 'scheme="https"' }
  end
end

control 'tomcat.logging_error_reporting' do
  impact 1.0
  title 'Verify that stack traces and server info are not reported'
  describe file(tomcat_conf + '/server.xml') do
    its('content') { should match 'showReport="false"' }
    its('content') { should match 'showServerInfo="false"' }
  end
end

control 'tomcat.crawler_session_manager' do
  impact 1.0
  title 'Ensuring that crawlers are associated with a single session'
  describe file(tomcat_conf + '/server.xml') do
    its('content') { should_not match 'hostAware="false"' }
    its('content') { should_not match 'contextAware="false"' }
  end
end

control 'tomcat.health_status' do
  impact 1.0
  title 'Health checks must be disabled'
  describe file(tomcat_conf + '/server.xml') do
    its('content') { should_not match 'org.apache.catalina.valves.HealthCheckValve' }
  end
end

control 'tomcat.context_privileged' do
  impact 1
  tag cis_id: 10.13
  tag cis_level: 1

  title 'Do not run applications as privileged'

  describe file(tomcat_conf + '/context.xml') do
    its('content') { should_not match 'privileged=”true”' }
  end
end

control 'tomcat.cross_context_requests' do
  impact 1
  tag cis_id: 10.14
  tag cis_level: 1

  title 'Do not run applications as privileged'

  describe file(tomcat_conf + '/context.xml') do
    its('content') { should_not match 'crossContext=”true”' }
  end
end

control 'tomcat.memory_leak_listener' do
  impact 1.0
  title 'Enable memory leak listener'

  tag cis_id: 10.16
  tag cis_level: 1

  describe file(tomcat_conf + '/server.xml') do
    its('content') { should match 'org.apache.catalina.core.JreMemoryLeakPreventionListener' }
  end
end
