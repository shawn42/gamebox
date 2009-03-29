#
# Crate recipe for rubygems version 1.3.1
#
Crate::Dependency.new( "rubygems", "1.3.1") do |t|
  t.upstream_source = "http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz"
  t.upstream_sha1   = "a21ae466146bffb28ece05cddbdced0b908ca74f"

  # TODO: figure out proper integration of rubygems, or just wait until 1.9
  #namespace t.name do
  #  desc "Integrate with ruby"
  #  task :integration => [ "ruby:patch", "#{t.name}:patch" ] do
  #    t.logger.info "Integrating #{t.name} into ruby's tree"
  #    Dir.chdir( File.join( t.pkg_dir, "lib" ) ) do |d|
  #      FileUtils.cp_r ".", Crate.ruby.lib_dir
  #    end
  #  end
  #end
end

