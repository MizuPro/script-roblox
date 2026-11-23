-- [[ .dominion X Licensed Loader ]]
-- https://github.com/MizuPro/script-roblox
(function()
    local okBoot, errBoot = pcall(function()
        print("[.dominion X Loader] Memulai aktivasi...")
        local API_BASE = "https://dominion-auth.vercel.app"
        local KEY_FILE = "DominionX_key.txt"

        local Http = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local okAnal, Analytics = pcall(function() return game:GetService("RbxAnalyticsService") end)
        local okCore, CoreGuiSvc = pcall(function() return game:GetService("CoreGui") end)

        local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local playerGui = lp:WaitForChild("PlayerGui", 10)
        local env = (type(getgenv) == "function" and getgenv()) or _G

        local reqFn = request
            or http_request
            or (syn and syn.request)
            or (fluxus and fluxus.request)
            or (http and http.request)
            or (env and (env.request or env.http_request))
            or (krnl and krnl.request)
        local loadFn = loadstring or load

        -- Helper safe mount UI (pola identik dengan 03_ui_foundation.lua: gethui -> CoreGui -> PlayerGui)
        local parentCandidates = {}
        if type(gethui) == "function" then
            local okG, g = pcall(gethui)
            if okG and g then parentCandidates[#parentCandidates + 1] = g end
        end
        if okCore and CoreGuiSvc then parentCandidates[#parentCandidates + 1] = CoreGuiSvc end
        if playerGui then parentCandidates[#parentCandidates + 1] = playerGui end

        for _, pr in ipairs(parentCandidates) do
            pcall(function()
                for _, old in ipairs(pr:GetChildren()) do
                    if old.Name == "DominionXAuthUI" then old:Destroy() end
                end
            end)
        end

        local sg = Instance.new("ScreenGui")
        sg.Name = "DominionXAuthUI"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 999999
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.IgnoreGuiInset = true
        sg.AutoLocalize = false

        local mounted = false
        if type(gethui) == "function" then
            mounted = pcall(function() sg.Parent = gethui() end)
        end
        if not mounted and okCore and CoreGuiSvc then
            mounted = pcall(function() sg.Parent = CoreGuiSvc end)
        end
        if not mounted and playerGui then
            mounted = pcall(function() sg.Parent = playerGui end)
        end
        if not mounted then
            warn("[.dominion X Loader] Gagal memasang ScreenGui ke gethui/CoreGui/PlayerGui!")
            return
        end

        -- UI Login .dominion X (Matte-Black & Cream Pro) - Langsung tampil instan!
        local win = Instance.new("Frame")
        win.Size = UDim2.new(0, 440, 0, 294)
        win.AnchorPoint = Vector2.new(0.5, 0.5)
        win.Position = UDim2.new(0.5, 0, 0.5, 0)
        win.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
        win.BorderSizePixel = 0
        win.Active = true
        win.ClipsDescendants = false
        win.Parent = sg
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke", win)
        stroke.Color = Color3.fromRGB(48, 48, 60)
        stroke.Thickness = 1.2

        local winScale = Instance.new("UIScale", win)
        winScale.Scale = 0.92
        TweenService:Create(winScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://6014261993"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.42
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(49, 49, 450, 450)
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
        shadow.Size = UDim2.new(1, 34, 1, 34)
        shadow.ZIndex = 0
        shadow.Parent = win

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, 0, 1, 0)
        body.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
        body.BorderSizePixel = 0
        body.ClipsDescendants = true
        body.ZIndex = 2
        body.Parent = win
        Instance.new("UICorner", body).CornerRadius = UDim.new(0, 12)

        local topStrip = Instance.new("Frame")
        topStrip.Size = UDim2.new(1, 0, 0, 2)
        topStrip.BackgroundColor3 = Color3.fromRGB(245, 239, 230)
        topStrip.BorderSizePixel = 0
        topStrip.ZIndex = 4
        topStrip.Parent = body
        local topGrad = Instance.new("UIGradient", topStrip)
        topGrad.Color = ColorSequence.new(Color3.fromRGB(245, 239, 230), Color3.fromRGB(120, 114, 106))

        -- Header Bar (Draggable)
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 50)
        header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        header.BorderSizePixel = 0
        header.Active = true
        header.ZIndex = 3
        header.Parent = body

        local hdrLine = Instance.new("Frame")
        hdrLine.Size = UDim2.new(1, -28, 0, 1)
        hdrLine.Position = UDim2.new(0, 14, 1, -1)
        hdrLine.BackgroundColor3 = Color3.fromRGB(36, 36, 46)
        hdrLine.BorderSizePixel = 0
        hdrLine.ZIndex = 4
        hdrLine.Parent = header

        do
            local dragging = false
            local dragStart, startPos
            header.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = inp.Position
                    startPos = win.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local delta = inp.Position - dragStart
                    win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        local mono = Instance.new("TextLabel")
        mono.Size = UDim2.new(0, 32, 0, 32)
        mono.Position = UDim2.new(0, 14, 0.5, -16)
        mono.BackgroundColor3 = Color3.fromRGB(245, 239, 230)
        mono.BorderSizePixel = 0
        mono.Font = Enum.Font.GothamBold
        mono.TextSize = 13
        mono.TextColor3 = Color3.fromRGB(11, 11, 14)
        mono.Text = ".dx"
        mono.ZIndex = 4
        mono.Parent = header
        Instance.new("UICorner", mono).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 175, 0, 18)
        title.Position = UDim2.new(0, 56, 0, 8)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = Color3.fromRGB(245, 239, 230)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = ".dominion X"
        title.ZIndex = 4
        title.Parent = header

        local subTitle = Instance.new("TextLabel")
        subTitle.Size = UDim2.new(0, 190, 0, 13)
        subTitle.Position = UDim2.new(0, 56, 0, 27)
        subTitle.BackgroundTransparency = 1
        subTitle.Font = Enum.Font.GothamBold
        subTitle.TextSize = 9
        subTitle.TextColor3 = Color3.fromRGB(145, 145, 160)
        subTitle.TextXAlignment = Enum.TextXAlignment.Left
        subTitle.Text = "LICENSE AUTHENTICATION"
        subTitle.ZIndex = 4
        subTitle.Parent = header

        local hwidBadge = Instance.new("Frame")
        hwidBadge.Size = UDim2.new(0, 88, 0, 20)
        hwidBadge.Position = UDim2.new(1, -134, 0.5, -10)
        hwidBadge.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
        hwidBadge.BorderSizePixel = 0
        hwidBadge.ZIndex = 4
        hwidBadge.Parent = header
        Instance.new("UICorner", hwidBadge).CornerRadius = UDim.new(0, 10)
        local hwidStroke = Instance.new("UIStroke", hwidBadge)
        hwidStroke.Color = Color3.fromRGB(48, 52, 66)
        local hwidDot = Instance.new("Frame")
        hwidDot.Size = UDim2.new(0, 6, 0, 6)
        hwidDot.Position = UDim2.new(0, 8, 0.5, -3)
        hwidDot.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
        hwidDot.BorderSizePixel = 0
        hwidDot.ZIndex = 5
        hwidDot.Parent = hwidBadge
        Instance.new("UICorner", hwidDot).CornerRadius = UDim.new(0, 3)
        local hwidTxt = Instance.new("TextLabel")
        hwidTxt.Size = UDim2.new(1, -18, 1, 0)
        hwidTxt.Position = UDim2.new(0, 17, 0, 0)
        hwidTxt.BackgroundTransparency = 1
        hwidTxt.Font = Enum.Font.GothamBold
        hwidTxt.TextSize = 8
        hwidTxt.TextColor3 = Color3.fromRGB(207, 199, 186)
        hwidTxt.TextXAlignment = Enum.TextXAlignment.Left
        hwidTxt.Text = "HWID LOCK"
        hwidTxt.ZIndex = 5
        hwidTxt.Parent = hwidBadge

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 26, 0, 26)
        closeBtn.Position = UDim2.new(1, -38, 0.5, -13)
        closeBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12
        closeBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
        closeBtn.Text = "X"
        closeBtn.AutoButtonColor = false
        closeBtn.BorderSizePixel = 0
        closeBtn.ZIndex = 4
        closeBtn.Parent = header
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(214, 70, 70), TextColor3 = Color3.new(1, 1, 1) }):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(24, 24, 32), TextColor3 = Color3.fromRGB(248, 113, 113) }):Play()
        end)
        closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

        -- Player Identity Strip
        local idCard = Instance.new("Frame")
        idCard.Size = UDim2.new(1, -28, 0, 42)
        idCard.Position = UDim2.new(0, 14, 0, 58)
        idCard.BackgroundColor3 = Color3.fromRGB(17, 17, 22)
        idCard.BorderSizePixel = 0
        idCard.ZIndex = 3
        idCard.Parent = body
        Instance.new("UICorner", idCard).CornerRadius = UDim.new(0, 8)
        local idStroke = Instance.new("UIStroke", idCard)
        idStroke.Color = Color3.fromRGB(38, 38, 48)

        local avImg = Instance.new("ImageLabel")
        avImg.Size = UDim2.new(0, 28, 0, 28)
        avImg.Position = UDim2.new(0, 8, 0.5, -14)
        avImg.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        avImg.BorderSizePixel = 0
        avImg.Image = ""
        avImg.ZIndex = 4
        avImg.Parent = idCard
        Instance.new("UICorner", avImg).CornerRadius = UDim.new(0, 14)
        task.spawn(function()
            local okT, url = pcall(function()
                return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if okT and type(url) == "string" and url ~= "" and avImg and avImg.Parent then
                avImg.Image = url
            end
        end)

        local dispName = (lp.DisplayName and lp.DisplayName ~= "" and lp.DisplayName) or lp.Name
        local pNameLbl = Instance.new("TextLabel")
        pNameLbl.Size = UDim2.new(1, -142, 0, 15)
        pNameLbl.Position = UDim2.new(0, 44, 0, 6)
        pNameLbl.BackgroundTransparency = 1
        pNameLbl.Font = Enum.Font.GothamBold
        pNameLbl.TextSize = 11
        pNameLbl.TextColor3 = Color3.fromRGB(245, 239, 230)
        pNameLbl.TextXAlignment = Enum.TextXAlignment.Left
        pNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        pNameLbl.Text = dispName
        pNameLbl.ZIndex = 4
        pNameLbl.Parent = idCard

        local pSubLbl = Instance.new("TextLabel")
        pSubLbl.Size = UDim2.new(1, -142, 0, 12)
        pSubLbl.Position = UDim2.new(0, 44, 0, 22)
        pSubLbl.BackgroundTransparency = 1
        pSubLbl.Font = Enum.Font.Gotham
        pSubLbl.TextSize = 9
        pSubLbl.TextColor3 = Color3.fromRGB(130, 130, 146)
        pSubLbl.TextXAlignment = Enum.TextXAlignment.Left
        pSubLbl.Text = "@" .. tostring(lp.Name) .. "  ·  ID " .. tostring(lp.UserId)
        pSubLbl.ZIndex = 4
        pSubLbl.Parent = idCard

        local readyPill = Instance.new("TextLabel")
        readyPill.Size = UDim2.new(0, 86, 0, 20)
        readyPill.Position = UDim2.new(1, -94, 0.5, -10)
        readyPill.BackgroundColor3 = Color3.fromRGB(22, 34, 28)
        readyPill.BorderSizePixel = 0
        readyPill.Font = Enum.Font.GothamBold
        readyPill.TextSize = 8
        readyPill.TextColor3 = Color3.fromRGB(74, 222, 128)
        readyPill.Text = "CLIENT READY"
        readyPill.ZIndex = 4
        readyPill.Parent = idCard
        Instance.new("UICorner", readyPill).CornerRadius = UDim.new(0, 6)

        -- License Key Input Label & Hint
        local keyLbl = Instance.new("TextLabel")
        keyLbl.Size = UDim2.new(0, 160, 0, 14)
        keyLbl.Position = UDim2.new(0, 14, 0, 110)
        keyLbl.BackgroundTransparency = 1
        keyLbl.Font = Enum.Font.GothamBold
        keyLbl.TextSize = 10
        keyLbl.TextColor3 = Color3.fromRGB(207, 199, 186)
        keyLbl.TextXAlignment = Enum.TextXAlignment.Left
        keyLbl.Text = "LICENSE KEY"
        keyLbl.ZIndex = 3
        keyLbl.Parent = body

        local fmtHint = Instance.new("TextLabel")
        fmtHint.Size = UDim2.new(0, 220, 0, 14)
        fmtHint.Position = UDim2.new(1, -234, 0, 110)
        fmtHint.BackgroundTransparency = 1
        fmtHint.Font = Enum.Font.Code
        fmtHint.TextSize = 9
        fmtHint.TextColor3 = Color3.fromRGB(115, 115, 130)
        fmtHint.TextXAlignment = Enum.TextXAlignment.Right
        fmtHint.Text = "DMX-XXXXX-XXXXX-XXXXX-XXXXX"
        fmtHint.ZIndex = 3
        fmtHint.Parent = body

        local hasClip = (type(getclipboard) == "function")
        local inputWrap = Instance.new("Frame")
        inputWrap.Size = UDim2.new(1, -28, 0, 38)
        inputWrap.Position = UDim2.new(0, 14, 0, 127)
        inputWrap.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        inputWrap.BorderSizePixel = 0
        inputWrap.ZIndex = 3
        inputWrap.Parent = body
        Instance.new("UICorner", inputWrap).CornerRadius = UDim.new(0, 8)
        local bStroke = Instance.new("UIStroke", inputWrap)
        bStroke.Color = Color3.fromRGB(52, 52, 66)
        bStroke.Thickness = 1.1

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, hasClip and -122 or -68, 1, 0)
        box.Position = UDim2.new(0, 12, 0, 0)
        box.BackgroundTransparency = 1
        box.Font = Enum.Font.Code
        box.TextSize = 12
        box.TextColor3 = Color3.fromRGB(245, 239, 230)
        box.PlaceholderText = "Tempel atau ketik license key Anda..."
        box.PlaceholderColor3 = Color3.fromRGB(95, 95, 110)
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Text = ""
        box.ZIndex = 4
        box.Parent = inputWrap
        box.Focused:Connect(function()
            TweenService:Create(bStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(245, 239, 230) }):Play()
        end)
        box.FocusLost:Connect(function()
            TweenService:Create(bStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(52, 52, 66) }):Play()
        end)

        if hasClip then
            local pasteBtn = Instance.new("TextButton")
            pasteBtn.Size = UDim2.new(0, 48, 0, 26)
            pasteBtn.Position = UDim2.new(1, -106, 0.5, -13)
            pasteBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            pasteBtn.BorderSizePixel = 0
            pasteBtn.Font = Enum.Font.GothamBold
            pasteBtn.TextSize = 9
            pasteBtn.TextColor3 = Color3.fromRGB(245, 239, 230)
            pasteBtn.Text = "PASTE"
            pasteBtn.ZIndex = 4
            pasteBtn.Parent = inputWrap
            Instance.new("UICorner", pasteBtn).CornerRadius = UDim.new(0, 5)
            pasteBtn.MouseButton1Click:Connect(function()
                local okC, clip = pcall(getclipboard)
                if okC and type(clip) == "string" then
                    box.Text = clip:gsub("%s+", "")
                end
            end)
        end

        local clearBtn = Instance.new("TextButton")
        clearBtn.Size = UDim2.new(0, 48, 0, 26)
        clearBtn.Position = UDim2.new(1, -54, 0.5, -13)
        clearBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        clearBtn.BorderSizePixel = 0
        clearBtn.Font = Enum.Font.GothamBold
        clearBtn.TextSize = 9
        clearBtn.TextColor3 = Color3.fromRGB(207, 199, 186)
        clearBtn.Text = "CLEAR"
        clearBtn.ZIndex = 4
        clearBtn.Parent = inputWrap
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)

        -- Status Banner Card
        local statusCard = Instance.new("Frame")
        statusCard.Size = UDim2.new(1, -28, 0, 38)
        statusCard.Position = UDim2.new(0, 14, 0, 174)
        statusCard.BackgroundColor3 = Color3.fromRGB(16, 16, 21)
        statusCard.BorderSizePixel = 0
        statusCard.ZIndex = 3
        statusCard.Parent = body
        Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 7)
        local stStroke = Instance.new("UIStroke", statusCard)
        stStroke.Color = Color3.fromRGB(36, 36, 46)

        local statusDot = Instance.new("Frame")
        statusDot.Size = UDim2.new(0, 7, 0, 7)
        statusDot.Position = UDim2.new(0, 11, 0.5, -3.5)
        statusDot.BackgroundColor3 = Color3.fromRGB(207, 199, 186)
        statusDot.BorderSizePixel = 0
        statusDot.ZIndex = 4
        statusDot.Parent = statusCard
        Instance.new("UICorner", statusDot).CornerRadius = UDim.new(0, 4)

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -32, 1, -4)
        statusLbl.Position = UDim2.new(0, 25, 0, 2)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Font = Enum.Font.GothamMedium
        statusLbl.TextSize = 10
        statusLbl.TextColor3 = Color3.fromRGB(207, 199, 186)
        statusLbl.TextWrapped = true
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Text = "Siap memverifikasi lisensi pada perangkat ini."
        statusLbl.ZIndex = 4
        statusLbl.Parent = statusCard

        local loginBtn = Instance.new("TextButton")
        loginBtn.Size = UDim2.new(1, -28, 0, 40)
        loginBtn.Position = UDim2.new(0, 14, 0, 222)
        loginBtn.BackgroundColor3 = Color3.fromRGB(245, 239, 230)
        loginBtn.BorderSizePixel = 0
        loginBtn.Font = Enum.Font.GothamBold
        loginBtn.TextSize = 12
        loginBtn.TextColor3 = Color3.fromRGB(11, 11, 14)
        loginBtn.Text = "AKTIVASI & JALANKAN"
        loginBtn.AutoButtonColor = false
        loginBtn.ZIndex = 3
        loginBtn.Parent = body
        Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)
        loginBtn.MouseEnter:Connect(function()
            TweenService:Create(loginBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(255, 252, 245) }):Play()
        end)
        loginBtn.MouseLeave:Connect(function()
            TweenService:Create(loginBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(245, 239, 230) }):Play()
        end)

        local footL = Instance.new("TextLabel")
        footL.Size = UDim2.new(0.6, 0, 0, 14)
        footL.Position = UDim2.new(0, 14, 1, -22)
        footL.BackgroundTransparency = 1
        footL.Font = Enum.Font.Gotham
        footL.TextSize = 9
        footL.TextColor3 = Color3.fromRGB(105, 105, 120)
        footL.TextXAlignment = Enum.TextXAlignment.Left
        footL.Text = "Dominion Auth · AES-256 + HMAC"
        footL.ZIndex = 3
        footL.Parent = body

        local footR = Instance.new("TextLabel")
        footR.Size = UDim2.new(0.35, 0, 0, 14)
        footR.Position = UDim2.new(0.65, -14, 1, -22)
        footR.BackgroundTransparency = 1
        footR.Font = Enum.Font.GothamBold
        footR.TextSize = 9
        footR.TextColor3 = Color3.fromRGB(130, 130, 146)
        footR.TextXAlignment = Enum.TextXAlignment.Right
        footR.Text = "Auto-Save Key"
        footR.ZIndex = 3
        footR.Parent = body

        local function setStatus(msg, col)
            local c = col or Color3.fromRGB(207, 199, 186)
            if statusLbl and statusLbl.Parent then
                statusLbl.Text = tostring(msg or "")
                statusLbl.TextColor3 = c
            end
            if statusDot and statusDot.Parent then
                statusDot.BackgroundColor3 = c
            end
        end

        clearBtn.MouseButton1Click:Connect(function()
            box.Text = ""
            if type(delfile) == "function" and type(isfile) == "function" then
                pcall(function() if isfile(KEY_FILE) then delfile(KEY_FILE) end end)
            elseif type(writefile) == "function" then
                pcall(writefile, KEY_FILE, "")
            end
            setStatus("Key tersimpan dibersihkan.", Color3.fromRGB(207, 199, 186))
        end)

        if type(reqFn) ~= "function" then
            setStatus("ERROR: Executor kamu tidak mendukung HTTP request() untuk auth.", Color3.fromRGB(248, 113, 113))
            loginBtn.AutoButtonColor = false
            return
        end
        if type(loadFn) ~= "function" then
            setStatus("ERROR: Executor kamu tidak mendukung loadstring().", Color3.fromRGB(248, 113, 113))
            loginBtn.AutoButtonColor = false
            return
        end
        if type(bit32) ~= "table" then
            setStatus("ERROR: Executor kamu tidak memiliki library bit32.", Color3.fromRGB(248, 113, 113))
            return
        end

        -- Pure Luau SHA-256 (bit32)
        local band, bor, bxor, bnot, rshift, lshift, rrotate = bit32.band, bit32.bor, bit32.bxor, bit32.bnot, bit32.rshift, bit32.lshift, bit32.rrotate
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
                    local ch = bxor(band(e, f), band(bnot(e), g))
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
            local out = {}
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
            if not id and okAnal and Analytics then
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
            setStatus("1/3 Meminta challenge server...", Color3.fromRGB(245, 239, 230))
            local hwid = getHWID()
            local chOk, _, chData = postJsonWithRetry("/api/v1/auth/challenge", {
                hwid = hwid,
                place_id = game.PlaceId,
            })
            if not chOk or not chData.ok then
                return false, tostring(chData.message or "Challenge auth gagal.")
            end

            setStatus("2/3 Memverifikasi lisensi & HWID...", Color3.fromRGB(245, 239, 230))
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

            setStatus("3/3 Mendekripsi & memuat .dominion X...", Color3.fromRGB(245, 239, 230))
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
            env._DX_AUTH = {
                api_base = API_BASE,
                session_token = vData.session_token,
                hwid = hwid,
                plan_label = vData.plan_label or vData.plan_code,
                remaining_sec = tonumber(vData.remaining_sec) or 0,
                server_time = tonumber(vData.server_time) or clientNow,
                server_offset = (tonumber(vData.server_time) or clientNow) - clientNow,
                expires_epoch = (tonumber(vData.server_time) or clientNow) + (tonumber(vData.remaining_sec) or 0),
                base_clock = os.clock(),
                base_remaining = tonumber(vData.remaining_sec) or 0,
            }

            local fn, compErr = loadFn(decrypted)
            if not fn then
                return false, "Gagal kompilasi script: " .. tostring(compErr)
            end
            task.spawn(fn)
            return true, "Sukses! Memuat .dominion X..."
        end

        local busy = false
        local function tryLogin(keyInput)
            if busy then return end
            busy = true
            loginBtn.Text = "MEMVERIFIKASI..."
            task.spawn(function()
                local okRun, ok, msg = pcall(authenticateKey, keyInput)
                if okRun and ok then
                    setStatus(msg, Color3.fromRGB(52, 211, 153))
                    task.wait(0.45)
                    if sg and sg.Parent then sg:Destroy() end
                else
                    local errTxt = okRun and msg or ("Runtime error: " .. tostring(ok))
                    setStatus(errTxt, Color3.fromRGB(248, 113, 113))
                    loginBtn.Text = "AKTIVASI & JALANKAN"
                    busy = false
                end
            end)
        end

        loginBtn.MouseButton1Click:Connect(function()
            tryLogin(box.Text)
        end)

        -- Auto-isi & auto-login asinkron jika ada getgenv().DominionKey atau file key tersimpan
        local initialKey = tostring(env.DominionKey or ""):gsub("%s+", "")
        if initialKey == "" then initialKey = readSavedKey() end
        if initialKey ~= "" then
            box.Text = initialKey
            tryLogin(initialKey)
        end
    end)

    if not okBoot then
        warn("[.dominion X Loader FATAL] " .. tostring(errBoot))
    end
end)()
