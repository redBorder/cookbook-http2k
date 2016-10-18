Name: cookbook-http2k
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Http2k (n2kafka) cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-http2k
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/http2k
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/http2k/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/http2k
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/http2k/README.md

%pre

%post

%files
%defattr(0755,root,root)
/var/chef/cookbooks/http2k

%doc

%changelog
* Tue Oct 18 2016 Alberto Rodríguez <arodriguez@redborder.com> - 1.0.0-1
- first spec version
