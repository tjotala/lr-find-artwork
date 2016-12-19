--[[----------------------------------------------------------------------------

 Find Artwork
 Copyright 2016 Tapani Otala

--------------------------------------------------------------------------------

FindArtworkMenuItem.lua

------------------------------------------------------------------------------]]

-- Access the Lightroom SDK namespaces.
local LrLogger = import "LrLogger"
local LrApplication = import "LrApplication"
local LrTasks = import "LrTasks"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"
local LrDialogs = import "LrDialogs"

-- Create the logger and enable the print function.
local myLogger = LrLogger( "com.tjotala.lightroom.find-artwork" )
myLogger:enable( "logfile" ) -- Pass either a string or a table of actions.

local inspect = require 'inspect'

--------------------------------------------------------------------------------
-- Write trace information to the logger.

local function trace( message, ... )
	myLogger:tracef( message, unpack( arg ) )
end

--------------------------------------------------------------------------------
-- Launch a background task to go find photos with IPTC Artwork Shown metadata

local function getTargetCollection( catalog )
	local collection = nil
	catalog:withWriteAccessDo( LOC( "$$$/FindDuplicates/GetTargetCollection=Creating Target Collection" ),
		function( context )
			-- get the target collection
			collection = catalog:createCollectionSet("Artwork", nil, true)

			-- Clear the collection, if it isn't empty already
			--collection:removeAllPhotos()
		end
	)

	return collection
end

local function findArtwork()
	LrFunctionContext.postAsyncTaskWithContext( LOC( "$$$/FindArtwork/ProgressScopeTitle=Finding Artwork" ),
		function( context )
			trace( "findArtwork: enter" )
			local catalog = LrApplication.activeCatalog()
			local collection = getTargetCollection(catalog)

			local progressScope = LrProgressScope {
				title = LOC( "$$$/FindArtwork/ProgressScopeTitle=Finding Artwork" ),
				functionContext = context
			}
			progressScope:setCancelable( true )

			-- Enumerate through all selected photos in the catalog
			local photos = catalog:getTargetPhotos()
			trace( "checking %d photos", #photos )
			for i, photo in ipairs(photos) do
				if progressScope:isCanceled() then
					break
				end

				-- Update the progress bar
				local fileName = photo:getFormattedMetadata( "fileName" )
				progressScope:setCaption( LOC( "$$$/FindArtwork/ProgressCaption=^1 (^2 of ^3)", fileName, i, #photos ) )
				progressScope:setPortionComplete( i, #photos )

				trace( "photo %d of %d: %s", i, #photos, fileName )

				local artworks = photo:getFormattedMetadata( "artworksShown" )
				if artworks then
					trace( "got %d artworks", #artworks )
					local artist = artworks[1]['AOCreator']
					local subcollection = nil
					catalog:withWriteAccessDo( LOC( "$$$/FindArtwork/ActionName=Create Artist Collection" ),
						function( context )
							subcollection = catalog:createCollection(artist, collection, true)
						end
					)
					if subcollection then
						catalog:withWriteAccessDo( LOC( "$$$/FindArtwork/ActionName=Add Photo to Artist Collection" ),
							function( context )
								subcollection:addPhotos { photo }
							end
						)
					else
						LrDialogs.showError( LOC( "$$$/FindArtwork/FailedAdd=Failed to add collection for ^1", artist ) )
					end
				end

				if LrTasks.canYield() then
					LrTasks.yield()
				end
			end

			progressScope:done()
			catalog:setActiveSources { collection }

			trace( "findArtwork: exit" )
		end
	)
end

--------------------------------------------------------------------------------
-- Begin the search
findArtwork()
