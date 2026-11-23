-- [[ .dominion X Licensed Loader ]]
-- https://github.com/MizuPro/script-roblox
;(function()
    local API_BASE = "https://dominion-auth.vercel.app"
    local KEY_FILE = "DominionX_key.txt"
    local LOGO_URL = "https://raw.githubusercontent.com/MizuPro/script-roblox/refs/heads/main/dominion-logo.jpg"

    local Http = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local Analytics = game:GetService("RbxAnalyticsService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()

    local reqFn = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    local loadFn = loadstring or load
    if type(reqFn) ~= "function" or type(loadFn) ~= "function" then
        warn("[.dominion X] Executor tidak mendukung HTTP request() atau loadstring().")
        return
    end

    -- Pure Luau SHA-256 (bit32)
    local band, bor, bxor, rshift, lshift, rrotate = bit32.band, bit32.bor, bit32.bxor, bit32.rshift, bit32.lshift, bit32.rrotate
    local K = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    }
    local function sha256Bytes(msg)
        local len = #msg
        local bits = len * 8
        local bytes = {}
        for i = 1, len do bytes[i] = string.byte(msg, i) end
        bytes[#bytes + 1] = 0x80
        while (#bytes % 64) ~= 56 do bytes[#bytes + 1] = 0 end
        local hi = math.floor(bits / 4294967296)
        local lo = bits % 4294967296
        for i = 3, 0, -1 do bytes[#bytes + 1] = band(rshift(hi, i * 8), 255) end
        for i = 3, 0, -1 do bytes[#bytes + 1] = band(rshift(lo, i * 8), 255) end

        local H = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}
        local W = {}
        for chunk = 1, #bytes, 64 do
            for i = 1, 16 do
                local idx = chunk + (i - 1) * 4
                W[i] = bor(lshift(bytes[idx], 24), lshift(bytes[idx + 1], 16), lshift(bytes[idx + 2], 8), bytes[idx + 3])
            end
            for i = 17, 64 do
                local s0 = bxor(rrotate(W[i - 15], 7), rrotate(W[i - 15], 18), rshift(W[i - 15], 3))
                local s1 = bxor(rrotate(W[i - 2], 17), rrotate(W[i - 2], 19), rshift(W[i - 2], 10))
                W[i] = (W[i - 16] + s0 + W[i - 7] + s1) % 4294967296
            end
            local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
            for i = 1, 64 do
                local S1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
                local ch = bxor(band(e, f), band(bit32.bnot(e), g))
                local t1 = (h + S1 + ch + K[i] + W[i]) % 4294967296
                local S0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
                local maj = bxor(band(a, b), band(a, c), band(b, c))
                local t2 = (S0 + maj) % 4294967296
                h = g; g = f; f = e; e = (d + t1) % 4294967296
                d = c; c = b; b = a; a = (t1 + t2) % 4294967296
            end
            local vals = {a, b, c, d, e, f, g, h}
            for i = 1, 8 do H[i] = (H[i] + vals[i]) % 4294967296 end
        end
        local out = {}
        for i = 1, 8 do
            local w = H[i]
            out[#out + 1] = band(rshift(w, 24), 255)
            out[#out + 1] = band(rshift(w, 16), 255)
            out[#out + 1] = band(rshift(w, 8), 255)
            out[#out + 1] = band(w, 255)
        end
        return out
    end

    local function bytesToHex(arr)
        local t = {}
        for i = 1, #arr do t[i] = string.format("%02x", arr[i]) end
        return table.concat(t)
    end

    local b64Inv = {}
    do
        local alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        for i = 1, #alpha do b64Inv[string.byte(alpha, i)] = i - 1 end
    end

    local function b64DecodeBytes(str)
        local out, idx, n, o = {}, 1, #str, 1
        local eq = string.byte("=")
        while idx <= n do
            local b0 = string.byte(str, idx)
            local b1 = string.byte(str, idx + 1)
            local b2 = idx + 2 <= n and string.byte(str, idx + 2) or eq
            local b3 = idx + 3 <= n and string.byte(str, idx + 3) or eq
            local c0 = b64Inv[b0] or 0
            local c1 = b64Inv[b1] or 0
            local c2 = (b2 ~= eq) and b64Inv[b2] or nil
            local c3 = (b3 ~= eq) and b64Inv[b3] or nil
            local v = c0 * 262144 + c1 * 4096 + (c2 or 0) * 64 + (c3 or 0)
            out[o] = math.floor(v / 65536) % 256; o = o + 1
            if c2 ~= nil then out[o] = math.floor(v / 256) % 256; o = o + 1 end
            if c3 ~= nil then out[o] = v % 256; o = o + 1 end
            idx = idx + 4
        end
        return out
    end

    local function decryptSessionPayload(encB64, serverNonce, clientNonce, sessionToken)
        local d1 = sha256Bytes(serverNonce .. ":" .. clientNonce .. ":" .. sessionToken .. ":k1")
        local d2 = sha256Bytes(serverNonce .. ":" .. clientNonce .. ":" .. sessionToken .. ":k2")
        local sk = {}
        for i = 1, 32 do sk[i] = d1[i] end
        for i = 1, 16 do sk[32 + i] = d2[i] end
        local s = (d2[17] * 65536 + d2[18] * 256 + d2[19]) % 16777216
        local enc = b64DecodeBytes(encB64)
        local out = table.create(#enc)
        for k = 1, #enc do
            s = (s * 1664525 + 1013904223) % 16777216
            local ks = (math.floor(s / 65536) + sk[((k - 1) % 48) + 1]) % 256
            out[k] = string.char((enc[k] - ks) % 256)
        end
        return table.concat(out)
    end

    local function getHWID()
        local id = nil
        if type(gethwid) == "function" then
            local ok, v = pcall(gethwid)
            if ok and type(v) == "string" and #v >= 8 then id = v end
        end
        if not id then
            local ok, v = pcall(function() return Analytics:GetClientId() end)
            if ok and type(v) == "string" and #v >= 8 then id = v end
        end
        return tostring(id or ("u_" .. tostring(lp.UserId)))
    end

    local function randNonceHex()
        return Http:GenerateGUID(false):gsub("-", ""):lower()
    end

    local function postJsonWithRetry(path, bodyTbl)
        local url = API_BASE .. path
        local jsonStr = Http:JSONEncode(bodyTbl)
        local delays = {1, 2, 4}
        local lastErr = "Koneksi gagal"
        for attempt = 1, 3 do
            local okReq, resp = pcall(reqFn, {
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json",
                },
                Body = jsonStr,
            })
            if okReq and type(resp) == "table" and resp.Body then
                local status = tonumber(resp.StatusCode or resp.Status) or 0
                local okDec, dec = pcall(function() return Http:JSONDecode(resp.Body) end)
                if status >= 200 and status < 500 then
                    if okDec and type(dec) == "table" then
                        return true, status, dec
                    end
                end
                lastErr = "HTTP " .. tostring(status)
            else
                lastErr = tostring(resp or "Request timeout")
            end
            if attempt < 3 then task.wait(delays[attempt]) end
        end
        return false, 0, { ok = false, message = "Gagal menghubungi server auth (" .. lastErr .. ")" }
    end

    local function readSavedKey()
        if type(isfile) == "function" and type(readfile) == "function" then
            local ok, exist = pcall(isfile, KEY_FILE)
            if ok and exist then
                local okR, txt = pcall(readfile, KEY_FILE)
                if okR and type(txt) == "string" then
                    return txt:gsub("%s+", "")
                end
            end
        end
        return ""
    end

    local function saveKeyFile(k)
        if type(writefile) == "function" then
            pcall(writefile, KEY_FILE, k)
        end
    end

    local function authenticateKey(rawKey)
        local cleanKey = tostring(rawKey or ""):gsub("%s+", ""):upper()
        if #cleanKey < 10 then
            return false, "Masukkan License Key terlebih dahulu!"
        end
        local hwid = getHWID()
        local chOk, _, chData = postJsonWithRetry("/api/v1/auth/challenge", {
            hwid = hwid,
            place_id = game.PlaceId,
        })
        if not chOk or not chData.ok then
            return false, tostring(chData.message or "Challenge auth gagal.")
        end

        local clientNonce = randNonceHex()
        local vOk, _, vData = postJsonWithRetry("/api/v1/auth/verify", {
            challenge_id = chData.challenge_id,
            key = cleanKey,
            hwid = hwid,
            user_id = lp.UserId,
            place_id = game.PlaceId,
            client_nonce = clientNonce,
        })
        if not vOk or not vData.ok then
            return false, tostring(vData.message or "License key tidak valid / expired.")
        end

        local decrypted = decryptSessionPayload(
            vData.enc_payload,
            chData.server_nonce,
            clientNonce,
            vData.session_token
        )
        local actualSha = bytesToHex(sha256Bytes(decrypted))
        if actualSha ~= vData.payload_sha256 then
            return false, "Integritas payload gagal diverifikasi!"
        end

        saveKeyFile(cleanKey)
        local clientNow = os.time()
        getgenv()._DX_AUTH = {
            api_base = API_BASE,
            session_token = vData.session_token,
            hwid = hwid,
            plan_label = vData.plan_label or vData.plan_code,
            remaining_sec = tonumber(vData.remaining_sec) or 0,
            server_time = tonumber(vData.server_time) or clientNow,
            server_offset = (tonumber(vData.server_time) or clientNow) - clientNow,
            expires_epoch = (tonumber(vData.server_time) or clientNow) + (tonumber(vData.remaining_sec) or 0),
        }

        local fn, compErr = loadFn(decrypted)
        if not fn then
            return false, "Gagal kompilasi script: " .. tostring(compErr)
        end
        task.spawn(fn)
        return true, "Sukses! Memuat .dominion X..."
    end

    -- Jika key sudah tersimpan via getgenv().DominionKey atau DominionX_key.txt, coba auto-login dulu
    local initialKey = tostring(getgenv().DominionKey or ""):gsub("%s+", "")
    if initialKey == "" then initialKey = readSavedKey() end
    if initialKey ~= "" then
        local okAuto, msgAuto = authenticateKey(initialKey)
        if okAuto then
            return
        end
        warn("[.dominion X Auth] Auto-login gagal:", msgAuto)
    end

    -- Tampilkan UI Login .dominion X (Matte-Black & Cream)
    local guiParent = (gethui and gethui()) or CoreGui or lp:WaitForChild("PlayerGui")
    for _, old in ipairs(guiParent:GetChildren()) do
        if old.Name == "DominionXAuthUI" then old:Destroy() end
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "DominionXAuthUI"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999999
    sg.AutoLocalize = false
    sg.Parent = guiParent

    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, 390, 0, 210)
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.new(0.5, 0, 0.5, 0)
    win.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
    win.BorderSizePixel = 0
    win.Parent = sg
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", win)
    stroke.Color = Color3.fromRGB(42, 42, 52)
    stroke.Thickness = 1.2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -56, 0, 36)
    title.Position = UDim2.new(0, 16, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextColor3 = Color3.fromRGB(245, 239, 230)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = ".dominion X  |  Aktivasi Lisensi"
    title.Parent = win

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -34, 0, 12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
    closeBtn.Text = "X"
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = win
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -32, 0, 18)
    sub.Position = UDim2.new(0, 16, 0, 44)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextColor3 = Color3.fromRGB(160, 160, 175)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Text = "Masukkan License Key (HWID Lock otomatis di perangkat ini):"
    sub.Parent = win

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -32, 0, 34)
    box.Position = UDim2.new(0, 16, 0, 68)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Code
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(245, 239, 230)
    box.PlaceholderText = "DMX-XXXXX-XXXXX-XXXXX-XXXXX"
    box.PlaceholderColor3 = Color3.fromRGB(95, 95, 110)
    box.ClearTextOnFocus = false
    box.Text = initialKey
    box.Parent = win
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", box)
    bStroke.Color = Color3.fromRGB(52, 52, 65)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -32, 0, 32)
    statusLbl.Position = UDim2.new(0, 16, 0, 108)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.GothamMedium
    statusLbl.TextSize = 11
    statusLbl.TextColor3 = Color3.fromRGB(207, 199, 186)
    statusLbl.TextWrapped = true
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Text = "Siap memverifikasi key."
    statusLbl.Parent = win

    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(1, -32, 0, 34)
    loginBtn.Position = UDim2.new(0, 16, 0, 154)
    loginBtn.BackgroundColor3 = Color3.fromRGB(245, 239, 230)
    loginBtn.BorderSizePixel = 0
    loginBtn.Font = Enum.Font.GothamBold
    loginBtn.TextSize = 13
    loginBtn.TextColor3 = Color3.fromRGB(11, 11, 13)
    loginBtn.Text = "VERIFIKASI & JALANKAN"
    loginBtn.Parent = win
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 6)

    local busy = false
    loginBtn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        loginBtn.Text = "MEMVERIFIKASI..."
        statusLbl.Text = "Menghubungi server lisensi..."
        statusLbl.TextColor3 = Color3.fromRGB(245, 239, 230)
        task.spawn(function()
            local ok, msg = authenticateKey(box.Text)
            if ok then
                statusLbl.Text = msg
                statusLbl.TextColor3 = Color3.fromRGB(52, 211, 153)
                task.wait(0.4)
                if sg and sg.Parent then sg:Destroy() end
            else
                statusLbl.Text = msg
                statusLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
                loginBtn.Text = "VERIFIKASI & JALANKAN"
                busy = false
            end
        end)
    end)
end)()
