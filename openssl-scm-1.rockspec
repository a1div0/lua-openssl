package = 'openssl'
version = 'scm-1'
source  = {
    url    = 'git@github.com:a1div0/lua-openssl.git',
    branch = 'master',
}
description = {
    summary  = "OpenSSL rock based https://github.com/zhaozg/lua-openssl",
    homepage = 'https://github.com/a1div0/lua-openssl',
    maintainer = "Alexander Klenov <a.a.klenov@ya.ru>",
    license  = 'None',
}
dependencies = {
    'lua >= 5.1',
}
build = {
    type = 'builtin',
    modules = {
        ['openssl'] = 'openssl/init.lua',
    },
    install = {
        lib = {'openssl/libssl.so'},
    }
}
