-- Jihad Bomb Sound Item Base Class
-- Follows Pointshop2 DLC pattern (like ps2-permaweaps)

ITEM.PrintName = "Jihad Bomb Sound Base"
ITEM.baseClass = "base_pointshop_item"
ITEM.category = "Sounds"
ITEM.static.isBase = true
ITEM.soundPath = ""

-- Shop icon panel
function ITEM.static:GetPointshopIconControl()
	return "DPointshopSoundIcon"
end

function ITEM.static:GetPointshopLowendIconControl()
	return "DPointshopSoundIcon"
end

-- Shop icon size (4x4 = 123x123px)
function ITEM.static.GetPointshopIconDimensions()
	return Pointshop2.GenerateIconSize(4, 4)
end

-- Link to persistence model
function ITEM.static.getPersistence()
	return Pointshop2.SoundItemPersistence
end

-- Generate item from database
-- CRITICAL: Methods must be explicitly copied to dynamic class!
function ITEM.static.generateFromPersistence(itemTable, persistenceItem)
	ITEM.super.generateFromPersistence(itemTable, persistenceItem.ItemPersistence)
	itemTable.soundPath = persistenceItem.soundPath or ""
	
	-- Copy instance methods
	itemTable.getIcon = ITEM.getIcon
	itemTable.getLowendInventoryIcon = ITEM.getLowendInventoryIcon
	itemTable.getCrashsafeIcon = ITEM.getCrashsafeIcon
	itemTable.getNewInventoryIcon = ITEM.getNewInventoryIcon
	itemTable.OnEquip = ITEM.OnEquip
	itemTable.OnHolster = ITEM.OnHolster
	itemTable.OnRemove = ITEM.OnRemove
	
	-- Copy static methods
	itemTable.static.GetPointshopIconControl = ITEM.static.GetPointshopIconControl
	itemTable.static.GetPointshopLowendIconControl = ITEM.static.GetPointshopLowendIconControl  
	itemTable.static.GetPointshopIconDimensions = ITEM.static.GetPointshopIconDimensions
	itemTable.static.getPersistence = ITEM.static.getPersistence
end

-- Inventory icon with music note
function ITEM:getIcon()
	if not CLIENT then return end
	
	local icon = vgui.Create("DPointshopInventoryItemIcon")
	icon:SetItem(self)
	icon:SetSize(64, 64)
	
	icon.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(40, 140, 200, 255))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		draw.SimpleText("♪", "DermaLarge", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	self.icon = nil
	return icon
end

-- Lowend inventory icon
function ITEM:getLowendInventoryIcon()
	if not CLIENT then return end
	
	self.icon = vgui.Create("DPointshopSimpleInventoryIcon")
	self.icon:SetItem(self)
	self.icon:SetSize(64, 64)
	return self.icon
end

-- Crashsafe icon (REQUIRED by Pointshop2)
function ITEM:getCrashsafeIcon()
	if not CLIENT then return end
	
	local icon
	if Pointshop2 and Pointshop2.ClientSettings and Pointshop2.ClientSettings.GetSetting then
		local lowend = Pointshop2.ClientSettings.GetSetting("BasicSettings.LowendMode")
		if lowend then
			icon = self:getLowendInventoryIcon()
		else
			icon = self:getIcon()
		end
	else
		icon = self:getIcon()
	end
	
	self.icon = nil
	return icon
end

-- Compatibility method
function ITEM:getNewInventoryIcon()
	if not CLIENT then return end
	
	if self.icon then
		local old = self.icon
		self.icon = nil
		local icon = self:getIcon()
		self.icon = old
		return icon
	else
		local icon = self:getIcon()
		self.icon = nil
		return icon
	end
end

-- Called when item is equipped
function ITEM:OnEquip()
	if not IsValid(self:GetOwner()) then return end
	
	local player = self:GetOwner()
	if Pointshop2 and Pointshop2.JihadIntegration and Pointshop2.JihadIntegration.SetPlayerSound then
		Pointshop2.JihadIntegration.SetPlayerSound(player, self)
	end
end

-- Called when item is unequipped
function ITEM:OnHolster()
	if not IsValid(self:GetOwner()) then return end
	
	local player = self:GetOwner()
	if Pointshop2 and Pointshop2.JihadIntegration and Pointshop2.JihadIntegration.SetPlayerSound then
		Pointshop2.JihadIntegration.SetPlayerSound(player, {soundPath = ""})
	end
end

-- Called when item is removed
function ITEM:OnRemove()
end
