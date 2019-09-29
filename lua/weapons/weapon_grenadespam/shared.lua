--Made by MrRangerLP.

if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldReady             = "grenade"
SWEP.HoldNormal            = "slam"

if CLIENT then
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV       = 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.PrintName			= "Grenadespam"
	SWEP.Instructions       = "Left Click: Spam Grenades\nRight Click: Throw Grenades as fast as you can click\nSprint + Left Click: Throw Grenades further away"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
	SWEP.Category			= "Other"
	killicon.Add("weapon_grenadespam","sprites/grenadespam",Color(255,255,255,255))
end

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.AutoSpawnable = true
SWEP.HoldType				= "grenade"

SWEP.ViewModel 				= "models/weapons/v_grenade.mdl"
SWEP.WorldModel 			= "models/weapons/w_grenade.mdl"

SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = true
SWEP.Primary.Delay         = 0.05
SWEP.Primary.Ammo          = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

function SWEP:Think()
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	if SERVER then
		self.Owner:DrawWorldModel(false)
		self.Owner:DrawWorldModel(false)
	end
end

function SWEP:Reload()
	return false
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if SERVER then
		local ent = ents.Create("npc_grenade_frag")
		
		ent.GrenadeOwner = self.Owner
		ent:SetPos(self.Owner:GetShootPos())
		ent:SetAngles(Angle(1,0,0))
		ent:Spawn()
		ent:Input("SetTimer",self:GetOwner(),self:GetOwner(),3)
	
		local phys = ent:GetPhysicsObject()
		if self.Owner:KeyDown(IN_SPEED)  then
			self.Primary.Delay = 0.1
			phys:SetVelocity(self.Owner:GetAimVector() * 50000)
		else 
			self.Primary.Delay = 0.01
			phys:SetVelocity(self.Owner:GetAimVector() * 1500)
		end
		
		hook.Remove("KeyPress", "GrenadeShitTemp")
		phys:AddAngleVelocity(Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)))
	end
	
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end


function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if SERVER then
		local ent = ents.Create("npc_grenade_frag")
		ent.GrenadeOwner = self.Owner
		ent:SetPos(self.Owner:GetShootPos())
		ent:SetAngles(Angle(1,0,0))
		ent:Spawn()
		ent:Input("SetTimer",self:GetOwner(),self:GetOwner(),3)
	
		local phys = ent:GetPhysicsObject()
		phys:SetVelocity(self.Owner:GetAimVector() * 1500)
		phys:AddAngleVelocity(Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)))
	end
	
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end