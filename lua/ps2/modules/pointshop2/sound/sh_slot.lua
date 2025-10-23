-- Register equipment slot for Jihad Bomb Sounds
-- Following the same pattern as base_playermodel (sh_slot.lua)

Pointshop2.AddEquipmentSlot( "Jihad Sound", function( item )
	-- Check if the item is a sound item
	if not item then
		return false
	end
	
	-- Check if item is instance of base_sound
	local soundBase = Pointshop2.GetItemClassByName( "base_sound" )
	if soundBase then
		return instanceOf( soundBase, item )
	end
	
	-- Fallback: check by class name (use lowercase!)
	if item.class and (item.class.className or item.class.ClassName) then
		local className = item.class.className or item.class.ClassName
		return string.find( className, "sound" ) ~= nil
	end
	
	return false
end, 0 )

KLogf( 4, "[PS2 Sounds] Equipment slot 'Jihad Sound' registered" )
