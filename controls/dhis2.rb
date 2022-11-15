# DHIS2 test

title 'DHIS2 test'

dhis2_custom_path = input('dhis2_custom_path', value: '/opt/dhis2')
dhis2_custom_user = input('dhis2_custom_user', value: 'tomcat')
hostname = input('container_name', value: `hostname`)
dhis2_local_url = input('dhis2_url', value: 'http://localhost:8080/' + hostname.gsub("\n",''))
os_version = input('os_version', value: 'ubuntu20.04')

only_if do
  file(dhis2_custom_path).exist?
end

control 'dhis-01' do
  impact 1.0
  title 'Server: Check DHIS2 folder owner, group and permissions.'
  desc 'The DHIS2 folder should owned by dhis2 or a defined user, only be writable by owner and readable by others.'
  describe file(dhis2_custom_path) do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by dhis2_custom_user }
    it { should be_grouped_into os.darwin? ? 'wheel' : dhis2_custom_user }
    it { should be_executable }
    it { should be_readable.by('owner') }
    it { should be_readable.by('group') }
    it { should be_readable.by('other') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('group') }
    it { should_not be_writable.by('other') }
  end
end

control 'dhis-02' do
  impact 1.0
  title 'Server: Check dhis.conf owner, group and permissions.'
  desc 'The dhis.conf should owned by dhis2 or a defined user, only be writable/readable by owner and not be executable.'

  describe file("#{dhis2_custom_path}/dhis.conf") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into os.darwin? ? 'wheel' : dhis2_custom_user }
    it { should_not be_executable }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('other') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('group') }
    it { should_not be_writable.by('other') }
  end
end

control 'dhis-03' do
  impact 1.0
  title 'Server: Check DHIS2 logs  owner, group and permissions.'
  desc 'The DHIS2 logs should owned by dhis2 or a defined user, only be writable/readable by owner and not be executable.'

  only_if do
    file("#{dhis2_custom_path}/logs").exist?
  end

  describe file("#{dhis2_custom_path}/logs") do
    it { should exist }
    it { should be_directory }
    it { should be_executable }
    it { should be_owned_by dhis2_custom_user }
    it { should be_grouped_into os.darwin? ? 'wheel' : dhis2_custom_user }
    it { should be_readable.by('owner') }
    it { should_not be_readable.by('other') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('other') }
  end
end

control 'dhis-04' do
  impact 1.0
  title 'Log files owner, group and permissions.'

  only_if do
    file("#{dhis2_custom_path}/logs").exist?
  end

  dirfiles = ::Dir.glob(dhis2_custom_path + '/logs/*').reject do |path|
    File.directory?(path)
  end
  dirfiles.each do |fname|
    describe file(fname) do
      it { should be_owned_by dhis2_custom_user }
      it { should be_grouped_into os.darwin? ? 'wheel' : dhis2_custom_user }
      it { should be_readable.by('owner') }
      it { should_not be_readable.by('other') }
      it { should be_writable.by('owner') }
      it { should_not be_writable.by('other') }
    end
  end
end

control 'dhis-05' do
  impact 1.0
  title 'Admin user credentials not default'

  describe http(dhis2_local_url + '/api/me', auth: {user: 'admin', pass: 'district'}, open_timeout: 60, read_timeout: 60, ssl_verify: false, max_redirects: 3) do
    its('status') { should eq 401 }
  end
end
