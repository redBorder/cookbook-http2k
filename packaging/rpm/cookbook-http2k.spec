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
if [ -d /var/chef/cookbooks/http2k ]; then
    rm -rf /var/chef/cookbooks/http2k
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload http2k'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/http2k ]; then
  rm -rf /var/chef/cookbooks/http2k
fi

%files
%attr(0755,root,root)
/var/chef/cookbooks/http2k
%defattr(0644,root,root)
/var/chef/cookbooks/http2k/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Tue Jan 09 2024 Vicente Mesa <vimesa@redborder.com>
- Delete .node on kafka brokers

* Mon Dec 18 2023 Vicente Mesa <vimesa@redborder.com>
- Fix kafka configuration on http2k service

* Fri Jan 07 2022 David Vanhoucke <dvanhoucke@redborder.com>
- change register to consul

* Tue Nov 16 2021 Jordi Hdez <jhernandez@redborder.com>
- first spec version

* Tue Oct 18 2016 Alberto Rodríguez <arodriguez@redborder.com>
- first spec version
