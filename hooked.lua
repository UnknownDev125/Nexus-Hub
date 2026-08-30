print("Hooked script loaded! Place ID:", game.PlaceId)
game:GetService("StarterGui"):SetCore("SendNotification",{Title="Nexus",Text="Hooked loaded!",Duration=5})
loadstring(game:HttpGet("https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked_full.lua"))()
