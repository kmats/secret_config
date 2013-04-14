$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'secret_config'
require 'secret1'
require 'secret2'

# create secret2.zip from secret2.zip.org
FileUtils.cp(File.expand_path('../secret2.zip.org', __FILE__),
             File.expand_path('../secret2.zip', __FILE__))
Kernel.at_exit { FileUtils.rm_f(File.expand_path('../secret2.yml', __FILE__)) }

