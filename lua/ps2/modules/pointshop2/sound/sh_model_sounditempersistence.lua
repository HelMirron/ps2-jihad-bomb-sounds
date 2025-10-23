-- Jihad Bomb Sound Persistence Model
-- Database schema for custom sound items using LibK ORM

Pointshop2.SoundItemPersistence = class( "Pointshop2.SoundItemPersistence" )
local SoundItemPersistence = Pointshop2.SoundItemPersistence

SoundItemPersistence.static.DB = "Pointshop2"

-- Database schema
SoundItemPersistence.static.model = {
	tableName = "ps2_soundpersistence",
	fields = {
		itemPersistenceId = "int",
		soundPath = "string",
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId",
			onDelete = "CASCADE",
		}
	}
}

SoundItemPersistence:include( DatabaseModel )
SoundItemPersistence:include( Pointshop2.EasyExport )

-- Save/update handler
function SoundItemPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
	local promise = Pointshop2.ItemPersistence.createOrUpdateFromSaveTable( saveTable, doUpdate )
	:Then( function( itemPersistence )
		if doUpdate then
			return SoundItemPersistence.findByItemPersistenceId( itemPersistence.id )
		else
			local soundInstance = SoundItemPersistence:new()
			soundInstance.itemPersistenceId = itemPersistence.id
			return soundInstance
		end
	end )
	:Then( function( soundInstance )
		soundInstance.soundPath = saveTable.soundPath or ""
		return soundInstance:save()
	end )

	return promise
end
