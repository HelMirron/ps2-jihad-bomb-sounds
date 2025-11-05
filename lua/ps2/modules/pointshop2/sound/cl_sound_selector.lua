-- Client-Side Sound Selector Panel
-- Sound browser with preview for admins

if not CLIENT then return end

local PANEL = {}

function PANEL:Init()
	self:SetSize( 700, 500 )
	self:SetTitle( "Jihad Bomb Sound Browser" )
	self:MakePopup()
	self:Center()
	
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:DockPadding( 10, 30, 10, 10 )
	
	-- Top bar mit Buttons
	local topBar = vgui.Create( "DPanel", self )
	topBar:Dock( TOP )
	topBar:SetHeight( 30 )
	topBar:DockMargin( 0, 0, 0, 10 )
	topBar.Paint = function() end
	
	local refreshBtn = vgui.Create( "DButton", topBar )
	refreshBtn:SetText( "Refresh" )
	refreshBtn:Dock( LEFT )
	refreshBtn:SetWidth( 100 )
	function refreshBtn.DoClick()
		net.Start( "PS2_RequestSoundList" )
		net.SendToServer()
	end
	
	-- Main content (2 columns: list + preview)
	local content = vgui.Create( "DPanel", self )
	content:Dock( FILL )
	content.Paint = function() end
	
	-- Left side: Sound list
	local leftPanel = vgui.Create( "DPanel", content )
	leftPanel:Dock( LEFT )
	leftPanel:SetWidth( 350 )
	leftPanel:DockMargin( 0, 0, 10, 0 )
	leftPanel.Paint = function() end
	
	local listLabel = vgui.Create( "DLabel", leftPanel )
	listLabel:SetText( "Available Sounds" )
	listLabel:Dock( TOP )
	listLabel:SetFont( self:GetSkin().SmallTitleFont )
	listLabel:SetColor( color_white )
	listLabel:SizeToContents()
	listLabel:DockMargin( 0, 0, 0, 5 )
	
	self.soundList = vgui.Create( "DListView", leftPanel )
	self.soundList:Dock( FILL )
	self.soundList:AddColumn( "Sound Name" )
	self.soundList:AddColumn( "Size" )
	self.soundList:SetDataHeight( 25 )
	
	function self.soundList:OnRowSelected( index, pnl )
		self:GetParent():GetParent():PreviewSound( pnl:GetColumnText( 1 ) )
	end
	
	-- Right side: Preview
	local rightPanel = vgui.Create( "DPanel", content )
	rightPanel:Dock( FILL )
	rightPanel.Paint = function() end
	
	local previewLabel = vgui.Create( "DLabel", rightPanel )
	previewLabel:SetText( "Sound Preview" )
	previewLabel:Dock( TOP )
	previewLabel:SetFont( self:GetSkin().SmallTitleFont )
	previewLabel:SetColor( color_white )
	previewLabel:SizeToContents()
	previewLabel:DockMargin( 0, 0, 0, 5 )
	
	self.previewPanel = vgui.Create( "DPanel", rightPanel )
	self.previewPanel:Dock( TOP )
	self.previewPanel:SetHeight( 150 )
	self.previewPanel:DockMargin( 0, 0, 0, 10 )
	Derma_Hook( self.previewPanel, "Paint", "Paint", "InnerPanel" )
	
	self.previewLabel = vgui.Create( "DLabel", self.previewPanel )
	self.previewLabel:Dock( TOP )
	self.previewLabel:SetText( "No sound selected" )
	self.previewLabel:SetFont( self:GetSkin().TextFont )
	self.previewLabel:DockMargin( 5, 5, 5, 5 )
	self.previewLabel:SizeToContents()
	
	local playBtn = vgui.Create( "DButton", self.previewPanel )
	playBtn:SetText( "▶ Play Preview" )
	playBtn:Dock( TOP )
	playBtn:SetHeight( 30 )
	playBtn:DockMargin( 5, 5, 5, 5 )
	
	local parent = self
	function playBtn.DoClick()
		if parent.selectedSound then
			parent:PlaySound( parent.selectedSound.path )
		end
	end
	
	-- Info Panel
	self.infoPanel = vgui.Create( "DScrollPanel", rightPanel )
	self.infoPanel:Dock( FILL )
	
	-- Network handler for sound list from server
	net.Receive( "PS2_SendSoundList", function( len )
		local sounds = net.ReadTable()
		if IsValid( parent ) then
			parent:PopulateSoundList( sounds )
		end
	end )
	
	-- Request sound list
	net.Start( "PS2_RequestSoundList" )
	net.SendToServer()
end

function PANEL:PopulateSoundList( sounds )
	self.soundList:Clear()
	
	for _, sound in ipairs( sounds ) do
		local line = self.soundList:AddLine( 
			sound.name,
			string.format( "%.2f KB", sound.size / 1024 )
		)
		line.sound = sound
	end
end

function PANEL:PreviewSound( soundName )
	for _, sound in ipairs( self.soundList:GetSorted() ) do
		if sound:GetColumnText( 1 ) == soundName then
			self.selectedSound = sound.sound
			self.previewLabel:SetText( "Sound: " .. soundName .. "\nPath: " .. self.selectedSound.path )
			break
		end
	end
end

function PANEL:PlaySound( soundPath )
	if soundPath then
		-- Mark as preview sound BEFORE playing to prevent global broadcast
		if Pointshop2 and Pointshop2.JihadIntegration and Pointshop2.JihadIntegration.MarkAsPreviewSound then
			Pointshop2.JihadIntegration.MarkAsPreviewSound( soundPath )
		end
		surface.PlaySound( soundPath )
	end
end

vgui.Register( "DSoundSelector", PANEL, "DFrame" )
