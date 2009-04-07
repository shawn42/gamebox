#
# The recipe for integrating amalgalite into the ruby build
#
Crate::GemIntegration.new("amalgalite", "0.7.1") do |t|
  t.upstream_source = "http://rubyforge.org/frs/download.php/50393/amalgalite-0.7.1.gem"
  t.upstream_sha1   = "84a84fd1192cef2d77701ec74afc8325a2a99ca7"
end
