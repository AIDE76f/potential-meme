local player = game.Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- التأكد من عدم تكرار الواجهة
if guiParent:FindFirstChild("CarScannerGUI") then
    guiParent.CarScannerGUI:Destroy()
end

--------------------------------------------------
-- 1. تصميم واجهة المستخدم (GUI)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarScannerGUI"
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🔍 معلومات أغلى سيارة"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 1, -100)
infoLabel.Position = UDim2.new(0, 10, 0, 50)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "جاري البحث عن كلمة 'ريال'..."
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 16
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 0, 35)
closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "إغلاق"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

--------------------------------------------------
-- 2. منطق البحث الذكي بناءً على كلمة "ريال"
--------------------------------------------------
local mostExpensiveCar = nil
local highestPrice = 0

-- مسح كل الكائنات
for _, object in pairs(workspace:GetDescendants()) do
    
    -- نبحث فقط في النصوص واللوحات المعروضة
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        local text = object.Text
        
        -- إذا وجدنا كلمة "ريال" في النص
        if string.find(text, "ريال") then
            
            -- نقوم بتنظيف النص من الفواصل والمسافات (مثل: 1,500,000 -> 1500000)
            local cleanText = string.gsub(text, ",", "")
            cleanText = string.gsub(cleanText, " ", "")
            
            -- نستخرج الأرقام فقط من النص
            local numberString = string.match(cleanText, "%d+")
            
            if numberString then
                local price = tonumber(numberString)
                
                -- إذا كان السعر المستخرج أكبر من أعلى سعر وجدناه حتى الآن
                if price and price > highestPrice then
                    
                    -- الآن نبحث عن مجسم السيارة الذي ينتمي إليه هذا النص
                    local parent = object.Parent
                    local carModel = nil
                    
                    -- نصعد في الشجرة (Parents) للبحث عن الـ Model (حد أقصى 15 خطوة للأعلى لتجنب التعليق)
                    local levels = 0
                    while parent and parent ~= workspace and levels < 15 do
                        if parent:IsA("Model") then
                            carModel = parent -- نحفظ آخر Model نمر عليه لأنه عادة ما يكون هو السيارة
                        end
                        parent = parent.Parent
                        levels = levels + 1
                    end
                    
                    if carModel then
                        highestPrice = price
                        mostExpensiveCar = carModel
                    end
                end
            end
        end
    end
end

--------------------------------------------------
-- 3. تحديث الواجهة بالنتائج
--------------------------------------------------
if mostExpensiveCar then
    local carName = mostExpensiveCar.Name
    local pos = mostExpensiveCar:GetPivot().Position
    
    local formattedPosition = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
    
    infoLabel.Text = 
        "🚗 الاسم: " .. carName .. "\n\n" ..
        "💰 السعر: " .. tostring(highestPrice) .. " ريال\n\n" ..
        "📍 المكان:\n" .. formattedPosition
else
    infoLabel.Text = "❌ لم يتم العثور على أي لوحة تحتوي على كلمة 'ريال' مرتبطة بسيارة في هذا الماب."
end
