#
# The recipe for integrating arrayfields into the ruby build
#
Crate::GemIntegration.new("arrayfields", "4.6.0") do |t|
  t.upstream_source  = "http://rubyforge.org/frs/download.php/39810/arrayfields-4.6.0.gem"
  t.upstream_sha1    = "d1caaea59a6cd37efbf769f12bd3340bbd3104bb"
end
