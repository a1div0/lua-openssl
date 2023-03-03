local luatest = require('luatest')
local jwt = require('cryptex.jwt')

local group = luatest.group()


local test_data = {
    payload = 'Unsigned brown fox jumps',
    more_payload = 'over the lazy dog',
    payload_num = 100500
}
local test_key = 'Salty secret salt'
local token_HS256 = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXlsb2FkIjoiVW5zaWduZWQgYnJvd24gZm94IGp1bXBzIiwibW9y'
        ..'ZV9wYXlsb2FkIjoib3ZlciB0aGUgbGF6eSBkb2ciLCJwYXlsb2FkX251bSI6MTAwNTAwfQ.YWZiN2U0MGRhZjNhZjhmYjlkZTRjMmQ3Y'
        ..'WUyZDBlMTdjYmFhMTBjMDUwMDBhNmE4N2NmNGM0NzE5MTgxNGZjNw'
local token_RS256 = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXlsb2FkIjoiVW5zaWduZWQgYnJvd24gZm94IGp1bXBzIiwibW9yZV9wY'
        ..'Xlsb2FkIjoib3ZlciB0aGUgbGF6eSBkb2ciLCJwYXlsb2FkX251bSI6MTAwNTAwfQ.ca1h8sHHmu1XW17vkaOThYuC5Nl2xQO60WAhj66hD9'
        ..'5JMz-Cm_86VQ2D68BcH9TtqgHSnHd9foG0ZmmRH2J5Ow01ajAeTWCp1CpHBRPtY07KIRiKBB9819FC2gqfNecKK9FEJOXbdj4bWH2xgoBDHp'
        ..'LvXFtScKlVwmBbMerU8LTE_4woa4LAJNQxOWseMLgEMGCMSaBvtsDST5VdktKwn71G1_-PnPzKzu9euXDqxfSr1SC-Ks4JVNnvvbKQBRz842'
        ..'tm9TZXBtWTHqJL-y7S4NfdOLO2vBcVZV4KjHyPCAUHu9fNVPSccayy_nPWtN6yli4-RGEXdNpDrgXpuxEljg'

local test_private_pem = [[-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDDK/2gkkjxFFt9
tTgqhpJx5pnErKxU0XImpLAHQVV3i+SkyTwS/8tmjRdpXA706uPt1yBcUKVINPqF
6I+O/Nax8I8x4/a7VUiPGNQbd0rUwokWl57WxQw/S+26rmsRi+Ao5QV1GgOYPooA
RzRitWPE00sCaTttzoWdedjy/MnNhEk7jjwanPbL2Min6uIDapn4jhAfczKg3XTK
qezl5RdHkFMe4cxv/WTChNfvil/bk8NXKBVXWO5elw9P6381dp1XCfqBoWOPDYgM
DDihncrTefxodzA/uOECNsDFE5+VCBzMwAoMi7yJygb0MrBslN254zembzxSih82
bq1tA2etAgMBAAECggEADSgwBt0VsbrPmB/ZU3SS9r626v1A+M7NxTEg9LxAyLhT
h5BRTm6UBavJQj8EexpCl0wDUHXXTpDTuqc81kTRLFmtLY3Smjpbk9n2ooteLg2X
NECwYoYSF0pFEmqjqSEm0VrvDT/dsiu1HeOu8mCMAz7DNbxmVzau5zjJmUfVStdb
7kW2b4reU5TkEQw94o8/oovMWFIyzmbg/Tq6WZACirLCcp2iiQserlwlDBHXxR18
qHgd1TIA1sf+trDhagEvCPXI49GA+z9rBWuWnaozWMRgsWbUp6q7EYhl/Pl9KzlY
1l4b3r+/ReKSshyDD9Dn083QrqLWcJvtPR2V5z/5QQKBgQDt7u6sznXCqddeyLLd
6m5mZNvsR5/hAq6NH3nwlQVyB6oiy6etk/xkeYK7aownHic3iWpmFcMVhlJbPwq9
6hqJbvPc6UTz6ptmbxUFkJ4Cs6/Ct6tBQXK9K5ParrrifH86gTLhEAKIdbpkdLyQ
+x7DJ6Yc7Z0LcvIDHSl94MoO6QKBgQDR/dbMTGzcYNztwf8tE3kA1Ed4UdNekBAd
FmbTY9vQqsoxZ4C/GGb/97jJpWP7YPy50Ho4KV+5gliMvVhY05xzvSjl/b3aVUUm
jD4Bgkq0IpZWj1UHEcduG7zFGFjYouB+Lt8yNTpls01ex1vdIqiJUg59FgYpuGb7
Pdf1cE1AJQKBgQCSzM9fuUZ443dpGKUbPE//Rw1Vm99t4cy2b4w5vogMkeQL8eEz
vFGF4F6jqZptbDJAFr2Z3KVvu19Gwv+qqyzSTK2TSC1t3PsiWTj8JP0Ip7qyhcXY
zjuvsZpY22Oc57lL7Hjq2YjmjtSAtHG/deDGAcmAoa46aSIef7ig3LduOQKBgQCl
+QLIMPOt76VPCpE8uHJgVGg00j/FMwp5YxZcqEW6FPOAvvUElS37zHkyb9Wpf0vh
NcUUFKeDQWHpw1JLyt2SoQTtW3OuWM0yHZB4stmGrPu0aM9kqgm9npDCG29Fst7K
/RMOZQHGFkTlz55tFxKsjr3C4iB24zgKBiRl6qA0PQKBgQC+bazYYWrYut2oKSxL
xYOyf3oQWARMhqX4a21b6O/JJVlzLHWYvlAGjmn+9OxsKT0yHhZFsyBoyYuF7khh
QQyS3uCAIQOmzTWD8ruyd7oq120FbiLipigNQPrsZFDcZhkzFhwDWn3FeQA5PgXm
JMdPxSzPGCYEP642FgdVNwweFw==
-----END PRIVATE KEY-----]]

local test_public_pem = [[-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwyv9oJJI8RRbfbU4KoaS
ceaZxKysVNFyJqSwB0FVd4vkpMk8Ev/LZo0XaVwO9Orj7dcgXFClSDT6heiPjvzW
sfCPMeP2u1VIjxjUG3dK1MKJFpee1sUMP0vtuq5rEYvgKOUFdRoDmD6KAEc0YrVj
xNNLAmk7bc6FnXnY8vzJzYRJO448Gpz2y9jIp+riA2qZ+I4QH3MyoN10yqns5eUX
R5BTHuHMb/1kwoTX74pf25PDVygVV1juXpcPT+t/NXadVwn6gaFjjw2IDAw4oZ3K
03n8aHcwP7jhAjbAxROflQgczMAKDIu8icoG9DKwbJTdueM3pm88UoofNm6tbQNn
rQIDAQAB
-----END PUBLIC KEY-----]]

group.test_encode_HS256 = function()

    local token, err = jwt.encode(test_data, test_key, 'HS256')
    luatest.assert_equals(err, nil)
    luatest.assert_equals(type(token), 'string')
    luatest.assert_equals(token, token_HS256)

end

group.test_encode_RS256 = function()

    local token, err = jwt.encode(test_data, test_private_pem, 'RS256')
    luatest.assert_equals(err, nil)
    luatest.assert_equals(type(token), 'string')
    luatest.assert_equals(token, token_RS256)

end

group.test_encode_unsupported_alg = function()

    local token, err = jwt.encode(test_data, test_private_pem, 'ABCD')
    luatest.assert_equals(token, nil)
    luatest.assert_equals(err, "Algorithm not supported")

end

group.test_decode_HS256 = function()

    local body, err = jwt.decode(token_HS256, test_key)
    luatest.assert_equals(err, nil)
    luatest.assert_equals(body, test_data)

end

group.test_decode_RS256 = function()

    local body, err = jwt.decode(token_RS256, test_public_pem)
    luatest.assert_equals(err, nil)
    luatest.assert_equals(body, test_data)

end
