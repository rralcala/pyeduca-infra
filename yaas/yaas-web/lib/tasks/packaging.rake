namespace :packaging do
  desc "Packaging"

  task(:buildrpm => :environment) do
    version = `grep Version #{Rails.root}/packaging/yaas-web.spec`.strip!
    vsplit = version.split(" ", 2)
    version = vsplit[1]
    system "git archive --format=tar --prefix=yaas-web-#{version}/ HEAD | gzip > #{Rails.root}/packaging/yaas-web-#{version}.tar.gz"
    system "rpmbuild -ba packaging/yaas-web.spec --define \"_sourcedir #{Rails.root}/packaging\""
  end
end
