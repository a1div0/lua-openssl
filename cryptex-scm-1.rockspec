package = 'cryptex'
version = 'scm-1'
source  = {
    url    = 'git@github.com:a1div0/tnt-cryptex.git',
    branch = 'master',
}
description = {
    summary  = 'Extended cryptography library for Lua',
    homepage = 'https://github.com/a1div0/tnt-cryptex',
    license  = 'None',
}
dependencies = {
    'lua >= 5.1',
}
build = {
    type = 'builtin',
    modules = {
        ['cryptex'] = 'cryptex/init.lua',
        ['cryptex.jwt'] = 'cryptex/jwt.lua',
    },
    install = {
        lib = {'cryptex/lua-openssl.so'},
    }
}
