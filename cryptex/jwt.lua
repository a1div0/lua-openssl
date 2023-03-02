-- luacheck: ignore 421

local lua_openssl = require("lua-openssl")
local tnt_digest_lib = require("digest")
local json = require("json")

local hmac = lua_openssl.hmac
local pkey_lib = lua_openssl.pkey
local jwt = {}

local function rsasha_encode(hash_alg, data, private_pem)
    local evp_pkey_private = pkey_lib.read(private_pem, true)
    local signature = evp_pkey_private:sign(data, hash_alg)
    return lua_openssl.hex(signature, true)
end

local function rsasha_verify(hash_alg, data, signature_str, public_pem)
    local signature = lua_openssl.hex(signature_str, false)
    local evp_pkey_public = pkey_lib.read(public_pem, false)
    return evp_pkey_public:verify(data, signature, hash_alg)
end

local alg_sign = {
    HS256 = function(data, key)
        return hmac.hmac("sha256", data, key, false)
    end,
    HS384 = function(data, key)
        return hmac.hmac("sha384", data, key, false)
    end,
    HS512 = function(data, key)
        return hmac.hmac("sha512", data, key, false)
    end,
    RS256 = function(data, key)
        return rsasha_encode("sha256", data, key)
    end,
    RS384 = function(data, key)
        return rsasha_encode("sha384", data, key)
    end,
    RS512 = function(data, key)
        return rsasha_encode("sha512", data, key)
    end,
}

local alg_verify = {
    HS256 = function(data, signature, key)
        return signature == alg_sign.HS256(data, key)
    end,
    HS384 = function(data, signature, key)
        return signature == alg_sign.HS384(data, key)
    end,
    HS512 = function(data, signature, key)
        return signature == alg_sign.HS512(data, key)
    end,
    RS256 = function(data, signature, key)
        return rsasha_verify("sha256", data, signature, key)
    end,
    RS384 = function(data, signature, key)
        return rsasha_verify("sha384", data, signature, key)
    end,
    RS512 = function(data, signature, key)
        return rsasha_verify("sha512", data, signature, key)
    end,
}

local function decode_token_items(header_b64, body_b64, sig_b64)

    local header_str = tnt_digest_lib.base64_decode(header_b64)
    local body_str = tnt_digest_lib.base64_decode(body_b64)
    local sig_str = tnt_digest_lib.base64_decode(sig_b64)

    local header = json.decode(header_str)
    local body = json.decode(body_str)

    return {
        header = header,
        body = body,
        signature = sig_str,
    }
end


---@comment Создаёт JWT-токен на основе входных данных.
---@comment В случае использования ассиметричных алгоритмов шифрования, в качестве ключа следует использовать
---@comment приватный ключ в формате PEM (PKCS8)
---@param data table Полезная нагрузка (данные) в виде таблицы. Например имя пользователя и перечень его прав.
---@param key string Ключ, используемый для подписи данного токена
---@param alg string Необязательный. Алгоритм формирования подписи, по умолчанию = HS256
---@return string JWT-токен
function jwt.encode(data, key, alg)

    if type(data) ~= "table" then
        return nil, "Argument #1 must be table"
    end
    if type(key) ~= "string" then
        return nil, "Argument #2 must be string"
    end

    alg = alg or "HS256"
    local hash_function = alg_sign[alg]
    if not hash_function then
        return nil, "Algorithm not supported"
    end

    local header = {
        typ = "JWT",
        alg = alg
    }
    local base64_encode_opt = {
        nopad = true,
        nowrap = true,
        urlsafe = true
    }

    local segments = {
        tnt_digest_lib.base64_encode(json.encode(header), base64_encode_opt),
        tnt_digest_lib.base64_encode(json.encode(data), base64_encode_opt)
    }

    local signing_input = table.concat(segments, ".")
    local ok, signature, err = pcall(hash_function, signing_input, key)
    if not ok or err then
        return nil, err or signature
    end

    segments[#segments + 1] = tnt_digest_lib.base64_encode(signature, base64_encode_opt)

    return table.concat(segments, ".")
end


---@comment Декодирует JWT-токен и проверяет подпись. В случае использования ассиметричных алгоритмов
---@comment шифрования, в качестве ключа следует использовать публичный ключ в формате PEM (PKCS8)
---@param jwt_token string JWT-токен
---@param key string Ключ, используемый для подписи данного токена (JSON Web Key)
---@param verify_prepare_func function Функция, вызываемая перед проверкой, параметр token_items содержит декодированные данные, params содержит ключ
---@param verify bool Необязательный. Параметр для отладочной среды. Если передать false - подпись проверяться не будет. По умолчанию = true.
---@return table Верифицированное тело токена
function jwt.decode(jwt_token, key, verify_prepare_func, verify)

    if type(jwt_token) ~= "string" then
        return nil, "Argument #1 must be string"
    end

    if type(key) ~= "string" then
        return nil, "Argument #2 must be string"
    end

    local token_items_str = jwt_token:split(".")
    if #token_items_str ~= 3 then
        return nil, "Invalid token"
    end

    local header_b64, body_b64, sig_b64 = token_items_str[1], token_items_str[2], token_items_str[3]
    local signing_input = header_b64 .. "." .. body_b64

    local ok, token_items = pcall(decode_token_items, header_b64, body_b64, sig_b64)
    if not ok then
        return nil, "Invalid json"
    end

    if not token_items.header.typ or token_items.header.typ ~= "JWT" then
        return nil, "Invalid typ"
    end

    if verify_prepare_func then
        local params = {key = key}
        verify_prepare_func(token_items, params)
        key = params.key
    end

    if verify ~= false then
        if not token_items.header.alg or type(token_items.header.alg) ~= "string" then
            return nil, "Invalid alg"
        end

        local verify_func = alg_verify[token_items.header.alg]
        if not verify_func then
            return nil, ("Algorithm '%s' is not supported"):format(token_items.header.alg)
        end

        local ok, result, err = pcall(verify_func, signing_input, token_items.signature, key)
        if not ok or err then
            return nil, err or result
        end
        if not result then
            return nil, "Invalid signature"
        end
    end

    return token_items.body
end

return jwt
