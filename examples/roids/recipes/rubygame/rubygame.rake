#
# The recipe for integrating rubygame into the ruby build
#
Crate::GemIntegration.new("rubygame", "2.4.1") do |t|
  t.upstream_source = "http://rubyforge.org/frs/download.php/51453/rubygame-2.4.1.gem"
end
