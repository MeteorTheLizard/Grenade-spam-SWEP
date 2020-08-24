--Made by MrRangerLP.

AddCSLuaFile("shared.lua")

if CLIENT then
	local Func = function() -- Selection Icon
		surface.CreateFont("WeaponIcons_m9k",{ -- Hl2 Font
			font = "HalfLife2",
			size = ScreenScale(48),
			weight = 500,
			antialias = true
		})

		surface.CreateFont("WeaponIconsSelected_m9k",{ -- Hl2 Outline Font
			font = "HalfLife2",
			size = ScreenScale(48),
			weight = 500,
			antialias = true,
			blursize = 10,
			scanlines = 3
		})
	end

	hook.Add("OnScreenSizeChanged","MMM_M9k_UpdateFontSize",Func) -- Resize selection icon according to screen resolution
	Func()

	killicon.AddAlias("weapon_grenadespam","weapon_frag") -- Killicon, probably not needed as its the grenade frag entity killing and not the weapon!

	function SWEP:PrintWeaponInfo(x,y,alpha) -- Taken from wiki to fix borders and remove autism
		if self.InfoMarkup == nil then
			self.InfoMarkup = markup.Parse("<font=HudSelectionText><color=230,230,230,255>Instructions:</color>\n<color=150,150,150,255>" .. self.Instructions .. "</color>\n</font>",300)
		end

		surface.SetDrawColor(60,60,60,alpha)
		surface.SetTexture(self.SpeechBubbleLid)
		surface.DrawTexturedRect(x,y - 64 - 5,128,64)
		draw.RoundedBox(8,x - 5,y - 6,309,self.InfoMarkup:GetHeight() + 18,Color(60,60,60,alpha))
		self.InfoMarkup:Draw(x + 5,y + 5,nil,nil,alpha)
	end

	local CachedColor1 = Color(255,235,0)
	function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
		draw.SimpleText("k","WeaponIconsSelected_m9k",x + wide / 2,y + tall * 0.02,CachedColor1,TEXT_ALIGN_CENTER)
		draw.SimpleText("k","WeaponIcons_m9k",x + wide / 2,y + tall * 0.02,CachedColor1,TEXT_ALIGN_CENTER)

		self:PrintWeaponInfo((x + 10) + wide + 20,(y + 10) + tall * 0.95,alpha)
	end
end

SWEP.PrintName = "GrenadeSpam"
SWEP.Category = "Other"
SWEP.Instructions = "Primary: Spam Grenades\nSecondary: Throw Grenades as fast as you can click\nPrimary + Sprint: Throw Grenades further away\nSecondary + Sprint: Throw Grenades further away as fast as you can click"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.HoldType = "grenade"
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55
SWEP.DrawCrosshair = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = SWEP.Primary.ClipSize
SWEP.Secondary.DefaultClip = SWEP.Primary.DefaultClip
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = SWEP.Primary.Ammo

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.OurIndex = self:EntIndex()

	if SERVER then
		self.UndoAnim = function()
			if not IsValid(self) then return end
			self:SendWeaponAnim(ACT_VM_DRAW)
		end
	end

	if SERVER and game.SinglePlayer() then -- In singleplayer we need to force the weapon to be equipped after spawning
		timer.Simple(0,function()
			if not IsValid(self) then return end -- We need to abort when the owner already had the weapon!
			self.Owner:SelectWeapon(self:GetClass())
		end)
	end

	if CLIENT and self.Owner == LocalPlayer() then
		self:SendWeaponAnim(ACT_VM_IDLE)

		if self.Owner:GetActiveWeapon() == self then -- Compat/Bugfix
			self:Equip()
			self:Deploy()
		end
	end
end

function SWEP:Equip()
	if SERVER and not self.Owner:IsPlayer() then
		self:Remove()
		return
	end
end

function SWEP:Deploy()
	if SERVER and game.SinglePlayer() then self:CallOnClient("Deploy") end -- Make sure that it runs on the CLIENT!
	self:SetHoldType(self.HoldType)

	local vm = self.Owner:GetViewModel()
	if IsValid(vm) then -- This is required since the code should only run on the server or on the player holding the gun (Causes errors otherwise)
		self:SendWeaponAnim(ACT_VM_DRAW)

		local Dur = vm:SequenceDuration() + 0.1
		self:SetNextPrimaryFire(CurTime() + Dur)
		self:SetNextSecondaryFire(CurTime() + Dur)
	end

	return true
end

function SWEP:Think()
end

function SWEP:Reload()
	return false
end

if SERVER then
	local AngleCache1 = Angle(0,0,-45)

	function SWEP:GrenadeSpawn()
		local Grenade = ents.Create("npc_grenade_frag")
		Grenade:SetPos(self.Owner:GetShootPos())
		Grenade:SetAngles(self.Owner:EyeAngles() + AngleCache1)
		Grenade:Spawn()
		Grenade:Input("SetTimer",self:GetOwner(),self:GetOwner(),3)

		local Phys = Grenade:GetPhysicsObject()
		if IsValid(Phys) then
			if self.Owner:KeyDown(IN_SPEED) then
				self:SetNextPrimaryFire(CurTime() + 0.1)
				self:SetNextSecondaryFire(CurTime() + 0.1)

				Phys:SetVelocity(self.Owner:GetAimVector() * 5000)
			else
				self:SetNextPrimaryFire(CurTime() + 0.01)
				self:SetNextSecondaryFire(CurTime() + 0.01)

				Phys:SetVelocity(self.Owner:GetAimVector() * 1500)
			end

			Phys:AddAngleVelocity(VectorRand(-50,50))
		end

		timer.Create("M9k_Grenadespam_" .. self.OurIndex,0.2,1,self.UndoAnim)
	end
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		self:GrenadeSpawn()
	end
end

function SWEP:SecondaryAttack()
	self:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		self:GrenadeSpawn()
	end
end