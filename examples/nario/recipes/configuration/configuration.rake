#
# The recipe for integrating configuration into the ruby build
#
Crate::GemIntegration.new("configuration", "0.0.5") do |t|
  t.upstream_source  = "http://rubyforge.org/frs/download.php/32720/configuration-0.0.5.gem"
  t.upstream_sha1    = "ae65a38666706959aaaa034fb7cb3d0234349ecc"
end
