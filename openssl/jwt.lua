local digest = require("tntssl")

local jwt = {}

---@comment Создаёт JWT-токен на основе входных данных
---@param data table Полезная нагрузка (данные) в виде таблицы. Например имя пользователя и перечень его прав.
---@param key string Ключ, используемый для подписи данного токена (JSON Web Key)
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

    if not alg_sign[alg] then
        return nil, "Algorithm not supported"
    end

    local header = {typ = "JWT", alg = alg}

    local segments = {
        digest.base64_encode(cjson.encode(header), {nopad = true, nowrap = true, urlsafe = true}),
        digest.base64_encode(cjson.encode(data), {nopad = true, nowrap = true, urlsafe = true})
    }

    local signing_input = table.concat(segments, ".")

    local signature = alg_sign[alg](signing_input, key)

    segments[#segments + 1] = digest.base64_encode(signature, {nopad = true, nowrap = true, urlsafe = true})

    return table.concat(segments, ".")
end

return jwt
