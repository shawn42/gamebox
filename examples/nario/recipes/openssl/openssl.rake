#
# Crate recipe for openssl
#
Crate::Dependency.new("openssl", "0.9.8j") do |t|
  t.depends_on( "zlib" )
  t.upstream_source = "http://openssl.org/source/openssl-0.9.8j.tar.gz"
  t.upstream_sha1   = "f70f7127a26e951e8a0d854c0c9e6b4c24df78e4"

  t.build_commands = [
    "./config --prefix=#{File.join( '/', 'usr' )} zlib no-threads no-shared",
    "make"
  ]

  t.install_commands = [
    "make install_sw INSTALL_PREFIX=#{t.install_dir}" ,
    "make clean"
  ]

end

