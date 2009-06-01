require '../config/environment'

libs = []
libs << ' -r console_app'

include_path = "-I " + $:.join(' -I ')
cmd = "irb #{include_path} #{libs.join(' ')} --simple-prompt"

exec cmd
