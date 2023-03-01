package = 'openssl'
version = '1.0.0-1'
source  = {
    url    = 'git@github.com:a1div0/lua-openssl.git',
    branch = 'master',
    tag = '1.0.0',
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
    install = {
        lib = {'openssl.so'},
    }
}
