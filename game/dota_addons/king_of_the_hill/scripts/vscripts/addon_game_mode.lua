-- Generated from template

if KingOfTheHillGameMode == nil then
	KingOfTheHillGameMode = class({})
end

function Precache( context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = KingOfTheHillGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function KingOfTheHillGameMode:InitGameMode()
	print("Activating")

	GameRules:GetGameModeEntity().KingOfTheHillGameMode = self
	self:InitTeams()
	
	for _,team in pairs(self.m_Teams) do
		GameRules:SetCustomGameTeamMaxPlayers(team.id, 1)
	end

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

function KingOfTheHillGameMode:InitTeams()
	print("Initializing teams")
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_BADGUYS] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan

	DOTA_TEAM_COUNT = table.getn(self.m_TeamColors)

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"

	self.POINTS_TO_WIN = 500
	self.CLOSE_TO_VICTORY_THRESHOLD = 400
	self.AMOUNT_OF_GOLD_FOR_KING = 50
	self.AMOUNT_OF_POINTS_FOR_KING = 10

	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 10 )
	GameRules:SetPreGameTime( 5 )
	GameRules:SetHideKillMessageHeaders( true )
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

	self.m_Teams = {}
	self.m_Teams[DOTA_TEAM_GOODGUYS] = {id = DOTA_TEAM_GOODGUYS, score = 0}
	self.m_Teams[DOTA_TEAM_BADGUYS]  = {id = DOTA_TEAM_BADGUYS , score = 0}
	self.m_Teams[DOTA_TEAM_CUSTOM_3] = {id = DOTA_TEAM_CUSTOM_3, score = 0}
	self.m_Teams[DOTA_TEAM_CUSTOM_4] = {id = DOTA_TEAM_CUSTOM_4, score = 0}
	self.m_Teams[DOTA_TEAM_CUSTOM_5] = {id = DOTA_TEAM_CUSTOM_5, score = 0}
	self.m_Teams[DOTA_TEAM_CUSTOM_6] = {id = DOTA_TEAM_CUSTOM_6, score = 0}

end

-- Evaluate the state of the game
function KingOfTheHillGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local players_to_score = FindUnitsInRadius(
			0,
			Vector(250,-256,816),
			nil,
			380,
			DOTA_UNIT_TARGET_TEAM_BOTH + DOTA_UNIT_TARGET_TEAM_CUSTOM,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED + DOTA_UNIT_TARGET_FLAG_NOT_DOMINATED + DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
			FIND_ANY_ORDER,
			false)
		for _,plr in ipairs(players_to_score) do
			self:InsertScore(plr:GetTeamNumber(), self.AMOUNT_OF_GOLD_FOR_KING)
			PlayerResource:ModifyGold( plr:GetPlayerID(), self.AMOUNT_OF_GOLD_FOR_KING, true, 0 )
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function KingOfTheHillGameMode:InsertScore(team, amount)
	self.m_Teams[team].score = self.m_Teams[team].score + amount
	for _,team in pairs(self.m_Teams) do
		print(team.id .. ": " .. team.score)
		if(team.score >= self.POINTS_TO_WIN) then
			GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[team.id] )
			GameRules:SetGameWinner(team.id)
		end
	end
end
