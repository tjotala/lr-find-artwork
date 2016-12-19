--[[----------------------------------------------------------------------------

 Find Photos with IPTC Artwork Shown
 Copyright 2016 Tapani Otala

--------------------------------------------------------------------------------

Info.lua
Summary information for the plug-in.

Adds menu items to Lightroom.

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 5.0,
	LrSdkMinimumVersion = 5.0, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = "com.tjotala.lightroom.find-artwork",

	LrPluginName = LOC( "$$$/FindArtwork/PluginName=Find Artwork" ),
	
	-- Add the menu item to the File menu.
	
	LrExportMenuItems = {
	    {
		    title = LOC( "$$$/FindArtwork/LibraryMenuItem=Find Artwork" ),
		    file = "FindArtworkMenuItem.lua",
		},
	},

	-- Add the menu item to the Library menu.
	
	LrLibraryMenuItems = {
	    {
		    title = LOC( "$$$/FindArtwork/LibraryMenuItem=Find Artwork" ),
		    file = "FindArtworkMenuItem.lua",
		},
	},

	VERSION = { major=1, minor=0, revision=0, build=1, },

}


	