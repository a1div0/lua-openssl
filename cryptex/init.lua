local lua_openssl = require("lua-openssl")
local jwt = require("cryptex.jwt")

local pkey_lib = lua_openssl.pkey

local function generate_rsa_pem_keys()
    local evp_pkey_private = pkey_lib.new('rsa')
    local private_pem = evp_pkey_private:export()
    local evp_pkey_public = evp_pkey_private:get_public()
    local public_pem = evp_pkey_public:export()

    return {
        private_pem = private_pem,
        public_pem = public_pem,
    }
end

return {
    openssl = lua_openssl,
    jwt = jwt,
    generate_rsa_pem_keys = generate_rsa_pem_keys,
}
