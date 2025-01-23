-- Ideacollection
-- Crusader Proc sound
function Comix_OnLoad()

  -- Registering Events -- 
  this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
  this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
  this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
  this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
  this:RegisterEvent("PLAYER_AURAS_CHANGED")
  this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
  this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
  this:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
  this:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  this:RegisterEvent("PLAYER_AURAS_CHANGED")
  this:RegisterEvent("PLAYER_TARGET_CHANGED")
  this:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
  this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
  this:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
  this:RegisterEvent("CHAT_MSG_YELL")
  this:RegisterEvent("UNIT_HEALTH")
  this:RegisterEvent("SPELLCAST_START")
  this:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  this:RegisterEvent("OnUpdate")
  this:RegisterEvent("READY_CHECK")
  this:RegisterEvent("RESURRECT_REQUEST")

  -- Saying Hello --
  DEFAULT_CHAT_FRAME:AddMessage("Hello you there, this AddOn is enabled by default!",0,0,1);
  
  -- Slash Commands --
  SlashCmdList["Comix"] = Comix_Command;
	SLASH_Comix1 = "/Comix";
	SLASH_Comix2 = "/comix";	

  -- Setting variables --
  Comix_x_coord = 0;
  Comix_y_coord = 0;
  Comix_Max_Scale = 2;
  ComixCurrentFrameCt = 1;
  ComixCritCount = 0;
  ComixBuffCount = 0;
  ComixAniSpeed = 1;
  ComixMaxCrits = 3;
  ComixKillCount = 0;
  Comix_CritPercent = 100;
  Comix_CritGap = 0;
  Comix_FinishHimGap = 0.2;
  Comix_CurrentImage = nil;
  Comix_NightfallCt = 0;
  Comix_Frames = {};
  Comix_FramesScale = {}
  Comix_FramesVisibleTime = {}
  Comix_FramesStatus = {}
  Comix_textures = {};
  Comix_SpecialsEnabled = true;
  Comix_KillCountEnabled = true;
  Comix_DeathSoundEnabled = true;
  ComixKillCountSoundPlayed = false;
  Comix_HuggedNotFound = false;
  Comix_AddOnEnabled = true;
  Comix_SoundEnabled = true;
  Comix_BS_Update = false;
  Comix_BSEnabled = true;
  Comix_JumpSoundEnabled = true;
  Comix_DemoShoutEnabled = true;
  Comix_ZoneEnabled = true;
  Comix_FinishTarget = true;
  Comix_BamEnabled = false;
  Comix_ImagesEnabled = true;
  Comix_FinishhimEnabled = true;
  Comix_NightfallProcced = true;
  Comix_NightfallEnabled = true;
  Comix_NightfallAutoTarget = false;
  Comix_NightfallCounter = false;
  Comix_CritGapEnabled = false;
  Comix_OneHit = false;
  Comix_NightfallAnnounce = false;
  Comix_NightfallGotTarget = false;
  Comix_BsShortDuration = true;
  Comix_HealorDmg = true;
  Comix_PlayerClass = UnitClass("player") 
  
  if GetLocale() == "frFR" then
    comix_loca = "fr"
  elseif GetLocale() == "deDE" then
    comix_loca = "de"
  else 
    comix_loca = "eng"
  end
  
  DEFAULT_CHAT_FRAME:AddMessage("Localisation set to "..comix_loca,0,0,1);   
  --getglobal("comix_"..comix_loca.."_fire")
 
  -- Hug Counter Variables --
  Comix_Hugs = {}
  Comix_Hugged = {}
  Comix_HugName = {}
  Comix_HugName[1] = UnitName("player")
  Comix_Hugs[1] = 0
  Comix_Hugged[1] = 0
  
  -- Calling functions to Create Frames and Load The Images/Sounds -- 
  Comix_CreateFrames(); 
  Comix_LoadFiles();
  TimeSinceLastUpdate = 0;
  Comix_DongSound(ComixSpecialSounds,6)

end

-- utility stuff
function comixprint(a)
  DEFAULT_CHAT_FRAME:AddMessage(" |cC60000FF[ComiX] |cffffffff" .. a)
end

local function UnitIsFriend()
  if UnitExists("target") and UnitCanAttack("player", "target") then      
      return false
  end
  return true
end

function Comix_OnEvent()

if (Comix_AddOnEnabled) then
  --finish him
  if event == "UNIT_HEALTH" then
    if Comix_FinishhimEnabled then          
      if Comix_FinishTarget then 
        if UnitHealth("Target") ~= nil and UnitHealth("Target") > 0 and UnitIsFriend() == false then         
          local TargetHealth = UnitHealth("Target")/UnitHealthMax("Target")
          if TargetHealth < Comix_FinishHimGap then
            Comix_DongSound(ComixSpecialSounds,12)
            Comix_FinishTarget = false
            Comix_OneHit = true;            
          end
        end  
      end    
    end  
  end
  
  if event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_COMBAT_SELF_HITS" then    
    -- last hit after finishhim
    if Comix_OneHit then
      if UnitHealth("target") <= 0 then
        Comix_OneHit = false;
        Comix_DongSound(ComixOneHitSounds,math.random(1,ComixOneHitSoundsCt))
      else
        Comix_OneHit = false;
      end  
    -- checks dmg max
    elseif Comix_CritGapEnabled then      
        if strfind(arg1, getglobal("comix_"..comix_loca.."_crits")) or 
           strfind(arg1, getglobal("comix_"..comix_loca.."_crit")) then
          local damagedone = 0;                    
          if strfind(arg1,'%d+') then   
            damagedone = tonumber(strsub(arg1, strfind(arg1,'%d+')))
          end  
          if damagedone > Comix_CritGap then
            local rndnumber = math.random(1,ComixOneHitSoundsCt)
            Comix_DongSound(ComixOneHitSounds,rndnumber)
            Comix_Pic(0,0,ComixMortalCombatImages[rndnumber])
          end
        end
    -- check crits
    else
      if ComixCritCount == 0 then
        if strfind(arg1, getglobal("comix_"..comix_loca.."_crits")) or 
           strfind(arg1, getglobal("comix_"..comix_loca.."_crit")) then
          ComixCritCount = 1
          if math.random(1,100) <= Comix_CritPercent then
           Comix_DongSound(ComixSounds)
           Comix_CallPic(Comix_DetermineDmgType(arg1))    
          end
        end
        
      elseif ComixCritCount < ComixMaxCrits then
        if strfind(arg1, getglobal("comix_"..comix_loca.."_crits")) or 
           strfind(arg1, getglobal("comix_"..comix_loca.."_crit")) then
          ComixCritCount = ComixCritCount+1
          if math.random(1,100) <= Comix_CritPercent then
            if ComixMaxCrits -1 ~= ComixCritCount then
              Comix_DongSound(ComixSounds)
            end  
            Comix_Pic(Comix_x_coord+10,Comix_y_coord-15,Comix_DetermineDmgType(arg1))    
          end
        else
          ComixCritCount = 0;
        end
             
      elseif ComixCritCount >= ComixMaxCrits then
        if strfind(arg1, getglobal("comix_"..comix_loca.."_crits")) or 
           strfind(arg1, getglobal("comix_"..comix_loca.."_crit")) then
          ComixCritCount = 0
          Comix_DongSound(ComixSpecialSounds,4)
          Comix_Pic(Comix_x_coord+math.random(-15,15),Comix_y_coord+math.random(-20,20),ComixSpecialImages[3])
        else
          ComixCritCount = 0;
        end
      end       
    end     
  end
  
  -- Readycheck
  if event == "READY_CHECK" then
    if Comix_SpecialsEnabled then
      Comix_DongSound(ComixReadySounds,math.random(1,ComixReadySoundsCt))
    end
  end

  -- Extra life!
  if event == "RESURRECT_REQUEST" then
    if Comix_SpecialsEnabled then
      Comix_DongSound(ComixRessSounds,math.random(1,ComixRessSoundsCt))
    end
  end

   -- phear teh mighty Pyroblast!!! --
   if event == "SPELLCAST_START" then
     if Comix_SpecialsEnabled then   
       if arg1 == "Pyroblast" then
         Comix_DongSound(ComixSpecialSounds,11)
       end
     end  
   end 
  -- Check Combatlog Events  
  if event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" or event == "CHAT_MSG_SPELL_PARTY_BUFF" or event == "CHAT_MSG_SPELL_SELF_BUFF" then  
    
    -- Gettin Battle Shout while not having the Buff --
    if Comix_BSEnabled then 
      if strfind(arg1,getglobal("comix_"..comix_loca.."_bs")) then
        Comix_Pic(0, 50,ComixSpecialImages[1])
        Comix_DongSound(ComixSpecialSounds,1)
        Comix_BS_Update = true
      end
    end
      -- Test your might, Recklessness
    if Comix_SpecialsEnabled then
      if strfind(arg1,getglobal("comix_"..comix_loca.."_reckless")) then 
        --if Comix_LongSpecialsEnabled then        
        --    Comix_DongSound(ComixSpecialSounds,23)
        --else
          Comix_DongSound(ComixSpecialSounds,22)
        --end
      end
    end
      -- I love speed, dont you love it too? sprint
    if Comix_SpecialsEnabled then 
      if strfind(arg1, getglobal("comix_"..comix_loca.."_sprint")) or strfind(arg1, getglobal("comix_"..comix_loca.."_dash")) then
        Comix_DongSound(ComixSpecialSounds,math.random(20,21))
      end   
    end          
   
   -- Healing Crits are Counted too... :P --     
    if Comix_CritGapEnabled then  
        if strfind(arg1, getglobal("comix_"..comix_loca.."_critically")) or 
           strfind(arg1, getglobal("comix_"..comix_loca.."_critically2")) then
          local healingdone = 0;
          if strfind(arg1,'%d+') then    
            healingdone = tonumber(strsub(arg1, strfind(arg1,'%d+')))
          end  

          
          if healingdone > Comix_CritGap then
            Comix_CallPic(Comix_DetermineDmgType(arg1))
            if Comix_CurrentImage == ComixHolyHealImages[2] then       
              Comix_DongSound(ComixHealingSounds,4)
            elseif Comix_BamEnabled then 
              Comix_DongSound(ComixSpecialSounds,13)            
            else 
              if Comix_HealorDmg then    
                Comix_DongSound(ComixHealingSounds,math.random(1,ComixHealingSoundsCt))
              end
            end
          end  
        end
      
    elseif ComixCritCount == 0 then
      if strfind(arg1, getglobal("comix_"..comix_loca.."_critically")) or strfind(arg1, getglobal("comix_"..comix_loca.."_critically2")) then
        ComixCritCount = 1
        Comix_CallPic(Comix_DetermineDmgType(arg1))
        if Comix_CurrentImage == ComixHolyHealImages[2] then       
          Comix_DongSound(ComixHealingSounds,4)
        elseif Comix_BamEnabled then 
          Comix_DongSound(ComixSpecialSounds,13)            
        else 
          if Comix_HealorDmg then    
            Comix_DongSound(ComixHealingSounds,math.random(1,ComixHealingSoundsCt-1))
          end 
        end    
      end
             
    elseif ComixCritCount < ComixMaxCrits then 
      if strfind(arg1, getglobal("comix_"..comix_loca.."_critically")) or strfind(arg1, getglobal("comix_"..comix_loca.."_critically2")) then
        ComixCritCount = ComixCritCount+1
        Comix_Pic(Comix_x_coord+math.random(-15,15),Comix_y_coord+math.random(-20,20),Comix_DetermineDmgType(arg1))
        if Comix_CurrentImage == ComixHolyHealImages[2] then       
          Comix_DongSound(ComixHealingSounds,4)
        elseif Comix_BamEnabled then 
          Comix_DongSound(ComixSpecialSounds,13)            
        else 
          if Comix_HealorDmg then    
            Comix_DongSound(ComixHealingSounds,math.random(1,ComixHealingSoundsCt-1))
          end 
        end    
      else
       ComixCritCount = 0;
      end
         
    elseif ComixCritCount >= ComixMaxCrits then
       if strfind(arg1, getglobal("comix_"..comix_loca.."_critically")) or strfind(arg1, getglobal("comix_"..comix_loca.."_critically2")) then
         ComixCritCount = 0
         Comix_DongSound(ComixSpecialSounds,4)
         Comix_Pic(Comix_x_coord+1,Comix_y_coord-15,ComixSpecialImages[3])
       else
         ComixCritCount = 0;
      end
    end        
  end

    -- Disabling the "OnUpdate" Version of Battle Shout when Buff Fades -- 
    if event =="CHAT_MSG_SPELL_AURA_GONE_SELF" then
      if strfind(arg1, getglobal("comix_"..comix_loca.."_bs")) then
        Comix_BS_Update = false
        Comix_BsShortDuration = true
      end
    end    
  -- Counting the Amount of Buffs --  
  if event == "PLAYER_AURAS_CHANGED" then
    for i = 0,15 do
      local BuffzorsBuffer = GetPlayerBuff(i)
      if BuffzorsBuffer == nil then
        return
      else
        ComixBuffCount = i;
      end 
    end        
  end
  -- Demo Shout & Nightfall Proc--   
  if event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" or
     event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
    if strfind(arg1,getglobal("comix_"..comix_loca.."_ds")) then
      if Comix_DemoShoutEnabled then
        Comix_Pic(0, 0,ComixSpecialImages[2])
        Comix_DongSound(ComixSpecialSounds,math.random(2,3))
      end
        
    elseif strfind(arg1,getglobal("comix_"..comix_loca.."_sv")) then
      if Comix_NightfallAnnounce then
        if Comix_NightfallEnabled then   
          SendChatMessage("[COMIX]NIGHTFALL PROCC ON "..UnitName("target"), "YELL", "Common")
          Comix_Pic(0,0,ComixSpecialImages[5])
          Comix_DongSound(ComixSpecialSounds,14)
          Comix_NightfallProcced = false;      
        end
      end  
    end 
  end
  
  if event == "CHAT_MSG_YELL" then
    if strfind(arg1,"NIGHTFALL PROCC ON ") and strfind(arg1,"COMIX") then
      if Comix_NightfallProcced then
        if Comix_NightfallGotTarget == false then
          Comix_Pic(0,0,ComixSpecialImages[5])
          Comix_DongSound(ComixSpecialSounds,14)  
          if Comix_NightfallAutoTarget then
            local targeto = strsub(arg1,27,strlen(arg1))
            if targeto ~= nil then
              DEFAULT_CHAT_FRAME:AddMessage("[Nightfall] : Autotargetting "..targeto.." by assisting "..arg2)
              AssistByName(arg2)
              Comix_NightfallCounter = true
              Comix_NightfallGotTarget = true
              Comix_NightfallCt = 0;
            end  
          end
        end 
      else
        Comix_NightfallProcced = true;
        Comix_NightfallGotTarget = false;
      end
    end     
  end
  -- Zone Changed Sounds -- 
  if Comix_ZoneEnabled then 
    if event == "ZONE_CHANGED_NEW_AREA" then
      Comix_DongSound(ComixZoneSounds,math.random(1,ComixZoneSoundsCt))
    end  
  end
  -- Bigglesworth Sound --
  if event == "PLAYER_TARGET_CHANGED" then
    if UnitName("target") == getglobal("comix_"..comix_loca.."_bigglesworth") then
      Comix_DongSound(ComixSpecialSounds,5)
      DEFAULT_CHAT_FRAME:AddMessage("[Dr. Evil] yells: That makes me angry and when Dr. Evil gets angry Mr. Bigglesworth gets upset and when Mr. Bigglesworth gets upset...... people DIE!",1,0,0)
    
    elseif UnitName("target") == getglobal("comix_"..comix_loca.."_repairbot") then
      Comix_DongSound(ComixSpecialSounds,7)
      DEFAULT_CHAT_FRAME:AddMessage("[Field Repair Bot 74A] says: All your base, r belong to us")
        
    end
    
    Comix_FinishTarget = true;
  end
       
  -- ... you dieded
  if event == "CHAT_MSG_COMBAT_FRIENDLY_DEATH" then
    if Comix_SpecialsEnabled then
      if UnitIsDead("player") and strfind(arg1, getglobal("comix_"..comix_loca.."_You")) then
        Comix_DongSound(ComixDeathSounds,math.random(1,ComixDeathSoundsCt))
        Comix_Pic(0, 50,ComixDeathImages[math.random(1,3)])
        ComixKillCount = 0;
      end
    end
  end      
  -- Slay some elite guy sound --
  if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
    if Comix_SpecialsEnabled then  
      if UnitIsPlusMob("target") and UnitLevel("target") > 60 then
        if strfind(arg1,getglobal("comix_"..comix_loca.."_You")) then
          Comix_DongSound(ComixSpecialSounds,9)
        end 
      end
    end  
  -- Kill Counter --  
    if Comix_KillCountEnabled then
      
      if strfind(arg1,getglobal("comix_"..comix_loca.."_You")) then
        ComixKillCount = ComixKillCount +1;
        ComixKillCountSoundPlayed = false; 
      end    
    
      if ComixKillCountSoundPlayed == false then  
        if ComixKillCount == 2 then
          Comix_DongSound(ComixKillCountSounds,1)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 5 then
          Comix_DongSound(ComixKillCountSounds,2)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 8 then
          Comix_DongSound(ComixKillCountSounds,3)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 10 then
          Comix_DongSound(ComixKillCountSounds,4)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 15 then
          Comix_DongSound(ComixKillCountSounds,5)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 20 then
          Comix_DongSound(ComixKillCountSounds,6)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 30 then
          Comix_DongSound(ComixKillCountSounds,7)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 40 then
          Comix_DongSound(ComixKillCountSounds,8)
          ComixKillCountSoundPlayed = true 
        elseif ComixKillCount == 50 then
          Comix_DongSound(ComixKillCountSounds,9)
          ComixKillCountSoundPlayed = true 
        end    
      end
    end  
  end
  
  -- Hug Coounter .. FU String Manipulation!!! -- 
  if event == "CHAT_MSG_TEXT_EMOTE" then
    if strfind(arg1, getglobal("comix_"..comix_loca.."_hug")) or strfind(arg1,getglobal("comix_"..comix_loca.."_hugs")) then
      local HuggerNotFound = true
      local HuggedNotFound = true   
      local comix_the_hugged_one = nil
      if strfind(arg1,getglobal("comix_"..comix_loca.."_hugs")) then
        if comix_loca == "fr" then
          comix_the_hugged_one = strsub(arg1,strfind(arg1,'%a+',13))
        else
          local gappie = tonumber(getglobal("comix_"..comix_loca.."_huggap")) 
          if arg2 == UnitName("player") then
            gappie = gappie + 3 
          else 
            gappie = gappie + strlen(arg2)
          end     
          comix_the_hugged_one = strsub(arg1,strfind(arg1,'%a+',gappie))
          
        end 
      elseif strfind(arg1,"vous serre ") then
        comix_the_hugged_one = UnitName("player")     
      elseif strfind(arg1, getglobal("comix_"..comix_loca.."_hug")) then        
        local gappie = tonumber(getglobal("comix_"..comix_loca.."_huggap")) 
        if arg2 == UnitName("player") then
          gappie = gappie + 3 
        else 
          gappie = gappie + strlen(arg2)
        end    
        comix_the_hugged_one = strsub(arg1,strfind(arg1,'%a+',gappie))
                
      end 
    
      if strfind(comix_the_hugged_one, getglobal("comix_"..comix_loca.."_you")) then
        comix_the_hugged_one = UnitName("player")
      end

        for i, line in ipairs(Comix_HugName) do
          if comix_the_hugged_one == getglobal("comix_"..comix_loca.."_you") then
            comix_the_hugged_one = UnitName("player")
          end

          if Comix_HugName[i] == arg2 then
            if not strfind(arg1, getglobal("comix_"..comix_loca.."_need")) then
              Comix_Hugs[i] = Comix_Hugs[i]+1
              HuggerNotFound = false
            end      
          end
          
          if Comix_HugName[i] == comix_the_hugged_one then
             Comix_Hugged[i] = Comix_Hugged[i]+1    
             HuggedNotFound = false
          end
        
        end
    
        if HuggedNotFound then
          if not strfind(arg1, getglobal("comix_"..comix_loca.."_need")) then
            Comix_HugName[getn(Comix_HugName)+1] = comix_the_hugged_one
            Comix_Hugged[getn(Comix_HugName)] = 1
            Comix_Hugs[getn(Comix_HugName)] = 0
            Comix_HuggedNotFound = false;
          end   
        end 
        
        if HuggerNotFound then
          if not strfind(arg1, getglobal("comix_"..comix_loca.."_need")) then
            Comix_HugName[getn(Comix_HugName)+1] = arg2
            Comix_Hugs[getn(Comix_HugName)] = 1
            Comix_Hugged[getn(Comix_HugName)] = 0
            Comix_HuggedNotFound = false;
          end 
        end
         
        for i,line in ipairs(Comix_HugName) do
          for j, line in ipairs(Comix_HugName) do
            if Comix_Hugged[i] > Comix_Hugged[j] then
              local Comix_TempHugged = Comix_Hugged[j]
              local Comix_TempHugs = Comix_Hugs[j]
              local Comix_TempHugName = Comix_HugName[j]
              Comix_Hugged[j] = Comix_Hugged[i]
              Comix_Hugs[j] = Comix_Hugs[i]
              Comix_HugName[j] = Comix_HugName[i]
              Comix_Hugged[i] = Comix_TempHugged
              Comix_Hugs[i] = Comix_TempHugs
              Comix_HugName[i] = Comix_TempHugName
            end  
          end
        end   
    end    
  end 
   
end  
end       

Comix_UpdateInterval = .01
function Comix_OnUpdate(elapsed)
local TimeSinceLastUpdate = 0;
if elapsed == nil then
  elapsed = 0
end

TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 
 
  while (TimeSinceLastUpdate > Comix_UpdateInterval) do
 
  -- Battleshout Buff Check if Battleshout is active  --
    if Comix_BS_Update then
      for i = 0,ComixBuffCount do
        local buffTexture = GetPlayerBuffTexture(i)
        if buffTexture ~= nil then
          if string.find(buffTexture,"BattleShout") then
            local timeLeft = tonumber(GetPlayerBuffTimeLeft(i))
            if (timeLeft <= 180.000)and (timeLeft >= 179.990) then
              Comix_BsShortDuration = false
              Comix_Pic(0, 0,ComixSpecialImages[1])
              Comix_DongSound(ComixSpecialSounds,1)
            elseif Comix_BsShortDuration then
              if (timeLeft <= 120.000)and (timeLeft >= 119.990) then
                Comix_Pic(0, 0,ComixSpecialImages[1])
                Comix_DongSound(ComixSpecialSounds,1)
              end
            elseif timeLeft < 119.00 then
               Comix_BsShortDuration = true    
            end      
          end
        end    
      end          
    end
  
  --The Picture Animation
    for i = 1,5 do
      if Comix_Frames[i] ~= nil then
        if Comix_Frames[i]:IsVisible() then
          if Comix_FramesStatus[i] == 0 then
            Comix_FramesScale[i] = Comix_FramesScale[i]*1.1*ComixAniSpeed 
            Comix_Frames[i]:SetScale(Comix_FramesScale[i])
            if Comix_FramesScale[i] >= Comix_Max_Scale then
              Comix_FramesStatus[i] = 1    
            end
          elseif Comix_FramesStatus[i] == 1 then
            Comix_FramesScale[i] = Comix_FramesScale[i]*0.8
            Comix_Frames[i]:SetScale(Comix_FramesScale[i])
            if Comix_FramesScale[i] >= Comix_Max_Scale*0.4 then
              Comix_FramesStatus[i] = 2
            end
          elseif Comix_FramesStatus[i] == 2 then
            Comix_FramesVisibleTime[i] = Comix_FramesVisibleTime[i] + 0.01
            if Comix_FramesVisibleTime[i] >= 1.0 then
              Comix_FramesStatus[i] = 3
            end  
          elseif Comix_FramesStatus[i] == 3 then
            Comix_FramesScale[i] = Comix_FramesScale[i]*0.5
            Comix_Frames[i]:SetScale(Comix_FramesScale[i])
            if Comix_FramesScale[i] <= 0.2 then
              Comix_Frames[i]:Hide()
              Comix_FramesStatus[i] = 0
              Comix_FramesScale[i] = 0.2
              Comix_FramesVisibleTime[i] = 0
            end
          end
        end            
      end    
    end  
  
  if Comix_NightfallCounter then
    Comix_NightfallCt = Comix_NightfallCt + elapsed
    if Comix_NightfallCt >= 5.0 then
      Comix_NightfallCounter = false;
      Comix_NightfallGotTarget = false;
      TargetLastTarget();
    end
  end 
    
  TimeSinceLastUpdate = TimeSinceLastUpdate-Comix_UpdateInterval;
  end   



end
	
function Comix_Command(Nerd)
  
  Nerd = strlower(Nerd)
   
  if (Nerd == "create") then 
    DEFAULT_CHAT_FRAME:AddMessage("Me Creates: Hello World")
    Comix_DongSound(ComixOneHitSounds,8)
    Comix_DongSound(ComixSpecialSounds,1)
    
  elseif (Nerd == "hide") then 
    Comix_Framehide();
  
  elseif (Nerd == "pic") then 
   Comix_CallPic(ComixImages[math.random(1,ComixImagesCt)]);
  
  elseif (Nerd == "on") then
    Comix_AddOnEnabled = true;
    Comix_Frame:Show()
    DEFAULT_CHAT_FRAME:AddMessage("Yeah m8, right thing done. You pwn.")

  elseif (Nerd == "off") then
    Comix_AddOnEnabled = false;
    Comix_Frame:Hide()
    DEFAULT_CHAT_FRAME:AddMessage("bah.... you deadhead ... disabling this pwn AddOn... nerd.")
  
  elseif (Nerd == "sound on") then
    Comix_SoundEnabled = true
    DEFAULT_CHAT_FRAME:AddMessage("Comix Sound is now turned on")   
  
  elseif (Nerd == "sound off") then
    Comix_SoundEnabled = false
        DEFAULT_CHAT_FRAME:AddMessage("Comix Sound is now turned off")  

  elseif (Nerd == "demoshout on") then
    Comix_SoundEnabled = true
    DEFAULT_CHAT_FRAME:AddMessage("Comix Demo Shout is now turned on")   
  
  elseif (Nerd == "demoshout off") then
    Comix_SoundEnabled = false
        DEFAULT_CHAT_FRAME:AddMessage("Comix Demo Shout is now turned off")  

  elseif (Nerd == "bs on") then
    Comix_SoundEnabled = true
    DEFAULT_CHAT_FRAME:AddMessage("Comix Battle Shout is now turned on")   
  
  elseif (Nerd == "bs off") then
    Comix_SoundEnabled = false
        DEFAULT_CHAT_FRAME:AddMessage("Comix Battle Shout is now turned off")  

  elseif (Nerd == "zoning on") then
    Comix_SoundEnabled = true
    DEFAULT_CHAT_FRAME:AddMessage("Comix Zoning Sounds are now turned on")   
  
  elseif (Nerd == "zoning off") then
    Comix_SoundEnabled = false
        DEFAULT_CHAT_FRAME:AddMessage("Comix Zoning Sound is now turned off")
  
  elseif (Nerd == "bam on") then
    Comix_BamEnabled = true
    
  elseif (Nerd == "bam off") then
    Comix_BamEnabled = false
    
  elseif (Nerd == "images on") then
    Comix_ImagesEnabled = true
  
  elseif (Nerd == "images off") then
    Comix_ImagesEnabled = false    
  
  elseif (Nerd == "finish on") then  
    Comix_FinishhimEnabled = true

  elseif (Nerd == "finish off") then  
    Comix_FinishhimEnabled = false
    
  elseif (Nerd == "dsound") then
    if Comix_DeathSoundEnabled then
      Comix_DeathSoundEnabled = false
      DEFAULT_CHAT_FRAME:AddMessage("Comix Death Sound is now turned off")
    else 
      Comix_DeathSoundEnabled = true
      DEFAULT_CHAT_FRAME:AddMessage("Comix Death Sound is now turned on")    
    end       
  
  elseif (Nerd == "nfall") then
    if Comix_NightfallAnnounce then
      Comix_NightfallAnnounce = false
      DEFAULT_CHAT_FRAME:AddMessage("Comix Night Fall Announce is now turned off")
    else 
      Comix_NightfallAnnounce = true
      DEFAULT_CHAT_FRAME:AddMessage("Comix Night Fall Announce is now turned on")    
    end 
  
  elseif (Nerd == "KillCount") then
    if Comix_KillCountEnabled then
      Comix_KillCountEnabled = false
      DEFAULT_CHAT_FRAME:AddMessage("Comix Kill Count is now turned off")
    else 
      Comix_KillCountEnabled = true
      DEFAULT_CHAT_FRAME:AddMessage("Comix Kill Count is now turned on")    
    end
     
  elseif string.find(Nerd,"anispeed") then    
    local ComixNerd = string.find(Nerd, " ")
    local buffer = tonumber(string.sub(Nerd, ComixNerd, ComixNerd + 1, string.len(Nerd)))
    if buffer < 1 or buffer > 3 then
      DEFAULT_CHAT_FRAME:AddMessage("Value not accepted, try smth between 1 and 3")
    else  
      ComixAniSpeed = buffer;
      DEFAULT_CHAT_FRAME:AddMessage("Animation Speed set to "..ComixAniSpeed)
    end
     
  elseif string.find(Nerd, "scale") then
    local ComixNerd = string.find(Nerd, " ")
    local scaleValue = string.sub(Nerd, ComixNerd + 1) 
    local buffer = tonumber(scaleValue)
    if buffer < 1.5 or buffer > 3 then
      DEFAULT_CHAT_FRAME:AddMessage("Value not accepted, try smth between 1.5 and 3")
    else  
      Comix_Max_Scale = buffer;
      DEFAULT_CHAT_FRAME:AddMessage("Scale set on "..Comix_Max_Scale)
    end
    
  elseif string.find(Nerd, "crits") then
    local ComixNerd = string.find(Nerd, " ")
    local buffer = tonumber(string.sub(Nerd, ComixNerd, ComixNerd + 1, string.len(Nerd)))
      ComixMaxCrits = buffer;
      DEFAULT_CHAT_FRAME:AddMessage("Amount of crits needed for Impressive set to "..ComixMaxCrits)
  
  elseif string.find(Nerd, "critpercent") then
    local ComixNerd = string.find(Nerd, " ")
    local buffer = tonumber(string.sub(Nerd, ComixNerd, ComixNerd + 1, string.len(Nerd)))
    if buffer <= 100 and buffer >= 0 then 
      Comix_CritPercent = buffer;
      DEFAULT_CHAT_FRAME:AddMessage("Amount of crits needed for Impressive set to "..ComixMaxCrits)
    else
      DEFAULT_CHAT_FRAME:AddMessage("You can set Crit-Percent only between 0 and 100 -.- anything else would be senseless or not??")
    end   
  
  elseif (Nerd == "clearhug") then
    for i, line in ipairs(Comix_HugName) do
      Comix_HugName[i] = nil ;
      Comix_Hugged[i] = nil;
      Comix_Hugs[i] = nil; 
    end 
    Comix_HugName[1] = UnitName("player")
    Comix_Hugs[1] = 0
    Comix_Hugged[1] = 0 
  
  elseif (Nerd == "showhug") then
    for i = 1,5 do
      if Comix_HugName[i] ~= nil then
        DEFAULT_CHAT_FRAME:AddMessage("[Hug Report]: "..Comix_HugName[i].."  has been hugged " ..Comix_Hugged[i].." times and Hugged "..Comix_Hugs[i].." times",0,0,1)
      end
    end 
  
  elseif (Nerd == "reporthug") then
    for i = 1,5 do
      if Comix_HugName[i] ~= nil then
        SendChatMessage("[Hug Report]: "..Comix_HugName[i].."  has been hugged " ..Comix_Hugged[i].." times and Hugged "..Comix_Hugs[i].." times", "SAY", getglobal("comix_"..comix_loca.."_language"))
      end
    end
       
  elseif (Nerd == "help") then
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix on|off to enable|disable AddOn")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix create to create a cool MSG")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix pic to show a Frame")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix hide to hide all Frames")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix scale <Value 1.5-3> to scale animation of all Frames")    
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix anispeed <Value 1-3> to set animation speed (popping up of the images)")    
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix sound on|off to turn sound on|off")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix demoshout on|off to turn Demo Shout grafix & sound on|off") 
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix bs on|off to turn Battle Shout grafix & sound on|off") 
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix zoning on|off to turn Zoning sounds on|off")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix crits <Value> to set the amount of crits needed for an Impressive")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix images on|off to show or hide the images on specials and crits")          
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix specials on|off to turn specials on or off ( eastereggs cant be turned off though :P )")
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix finish on|off to turn <Finish him>-sound on 20% mob health on or off")          
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix bam on|off to enable BamSound only or hear Comix Sounds on crits!")          
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix showhug to show the Hugs done in your Chat-Frame.") 
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix reporthug to report the Hugging done to /say.") 
    DEFAULT_CHAT_FRAME:AddMessage("Use /comix clearhug to clear all Hugs done.") 
  
  else 
    comix_options_frame:Show()
    
  end
  
end



function Comix_DongSound(SoundTable,Sound)

  if Comix_SoundEnabled then 
   if SoundTable == ComixSounds then  
     if Comix_BamEnabled then
       PlaySoundFile("Interface\\AddOns\\Comix\\Sounds\\"..ComixSpecialSounds[13])
     else  
       local randsound = math.random(1,ComixSoundsCt)
       PlaySoundFile("Interface\\AddOns\\Comix\\Sounds\\"..SoundTable[randsound]);
     end
   else 
     PlaySoundFile("Interface\\AddOns\\Comix\\Sounds\\"..SoundTable[Sound]);
   end
  end
   
end



function Comix_Pic(x,y,Pic)

  if Comix_ImagesEnabled then
-- Resetting Frames animation values --
    if Comix_Frames[ComixCurrentFrameCt]:IsVisible() then
      Comix_Frames[ComixCurrentFrameCt]:Hide()
    end  
    Comix_FramesStatus[ComixCurrentFrameCt] = 0
    Comix_FramesScale[ComixCurrentFrameCt] = 0.2
    Comix_FramesVisibleTime[ComixCurrentFrameCt] = 0 
   
-- Setting Texture --
    Comix_textures[ComixCurrentFrameCt]:SetTexture("Interface\\Addons\\Comix\\"..Pic);
    Comix_textures[ComixCurrentFrameCt]:SetAllPoints(Comix_Frames[ComixCurrentFrameCt]);
    Comix_Frames[ComixCurrentFrameCt].texture = Comix_textures[ComixCurrentFrameCt];
   
-- Positioning Frame --
     
    Comix_Frames[ComixCurrentFrameCt]:SetPoint("Center",x,y);
    Comix_Frames[ComixCurrentFrameCt]:Show();

-- Increasing Current Frame or resetting it to 1 --  
    if ComixCurrentFrameCt == 5 then
      ComixCurrentFrameCt = 1
    else
      ComixCurrentFrameCt = ComixCurrentFrameCt +1
    end
  end     
end  

function Comix_LoadFiles()

-- Counting Normal Images --  
  ComixImagesCt = getn(ComixImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixImagesCt.." piccus",0,0,0)

-- Counting Images in Image-Sets --
  ComixFireImagesCt = getn(ComixFireImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixFireImagesCt.." piccus",0,0,1)

  ComixFrostImagesCt = getn(ComixFrostImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixFrostImagesCt.." piccus",0,1,1)

  ComixShadowImagesCt = getn(ComixShadowImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixShadowImagesCt.." piccus",0,1,0)

  ComixNatureImagesCt = getn(ComixNatureImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixNatureImagesCt.." piccus",1,1,0)

  ComixArcaneImagesCt = getn(ComixArcaneImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixArcaneImagesCt.." piccus",1,0,0)

  ComixHolyHealImagesCt = getn(ComixHolyHealImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixHolyHealImagesCt.." piccus",0,0,0)

  ComixHolyDmgImagesCt = getn(ComixHolyDmgImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixHolyDmgImagesCt.." piccus",0,0,0)

  ComixDeathImagesCt = getn(ComixDeathImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixDeathImagesCt.." piccus",0,0,0)
-- Counting Normal Sounds --
  ComixSoundsCt = getn(ComixSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixSoundsCt.." sounds",1,0,1)

-- Counting Specials --
  ComixSpecialCt = getn(ComixSpecialImages)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixSpecialCt.." specials",1,0,0)  
  DEFAULT_CHAT_FRAME:AddMessage("Open options GUI with /comix or get Slashcommands with /comix help",0,0,1)

-- Counting Res Sounds --   
  ComixResSoundsCt = getn(ComixResSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixResSoundsCt.." sounds",1,1,1)

  -- Counting Ability Sounds --   not used yet
  ComixAbilitySoundsCt = getn(ComixAbilitySounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixAbilitySoundsCt.." sounds",1,1,1)

  -- Counting Readycheck Sounds --   
  ComixReadySoundsCt = getn(ComixReadySounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixReadySoundsCt.." sounds",1,1,1)

  -- Counting Death Sounds --   
  ComixDeathSoundsCt = getn(ComixDeathSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixDeathSoundsCt.." sounds",1,1,1)

  -- Killcount need no counter

  -- Counting Zone Sounds --
  ComixZoneSoundsCt = getn(ComixZoneSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixZoneSoundsCt.." sounds",1,1,1)

  -- Counting One hit Sounds --
  ComixOneHitSoundsCt = getn(ComixOneHitSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixOneHitSoundsCt.." sounds",1,1,1)
  
  -- Counting Healing Sounds --   
  ComixHealingSoundsCt = getn(ComixHealingSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixHealingSoundsCt.." sounds",1,1,1)

  -- Counting Nice Sounds --   
  ComixNiceSoundsCt = getn(ComixNiceSounds)
  DEFAULT_CHAT_FRAME:AddMessage("Me loaded "..ComixNiceSoundsCt.." sounds",1,1,1)
    
end

function Comix_Framehide()
 for i,line in ipairs(Comix_Frames) do
   Comix_Frames[i]:Hide();
   DEFAULT_CHAT_FRAME:AddMessage("Hiding Comix_Frames["..i.."]")
 end
end



function Comix_CallPic(Image)
  
  if Comix_ImagesEnabled then
-- Creating x,y Coordinates --
    Comix_x_coord = math.random(-120,120)
    if Comix_x_coord <= 0 then
      Comix_x_coord = Comix_x_coord -40
    else
      Comix_x_coord= Comix_x_coord +40
    end  
 
    if (abs(Comix_x_coord)<75) then
      local y_buffer = 50 
      Comix_y_coord = math.random(y_buffer,130)
    else
      Comix_y_coord = math.random(0,130)   
    end
  
-- Finally handing over x,y Coords and the image to show --
    Comix_CurrentImage = Image
    Comix_Pic(Comix_x_coord,Comix_y_coord,Image)
 end
 
end

function Comix_CreateFrames()
-- Creating 5 Frames, creating 5 Textures and setting FramesScale, FramesVisibleTime & FramesStatus--
  for i = 1,5 do
    -- Create Frame --
    Comix_Frames[i] = CreateFrame("Frame","Frame"..i,UIParent)
    Comix_Frames[i]:SetWidth(128);
    Comix_Frames[i]:SetHeight(128);
    Comix_Frames[i]:Hide()
    -- Create texture for each frame --
    Comix_textures[i] = Comix_Frames[i]:CreateTexture(nil,"BACKGROUND")
    -- Setting FramesScale, FramesVisibleTime & FramesStatus  to 0 --
    Comix_FramesScale[i] = 0.2
    Comix_FramesVisibleTime[i] = 0
    Comix_FramesStatus[i] = 0
  end

end  

function Comix_DetermineDmgType(DmgLine)
  
  if  strfind(DmgLine, getglobal("comix_"..comix_loca.."_heal")) then
    if Comix_PlayerClass == "Shaman" or "Druid" then
      Comix_HealorDmg = true
      return ComixHolyHealImages[math.random(1,ComixHolyHealImagesCt)]  
    elseif Comix_PlayerClass =="Paladin" then
      Comix_HealorDmg = true
      return ComixHolyHealImages[math.random(1,ComixHolyHealImagesCt)]    
    else 
      Comix_HealorDmg = true
      return ComixHolyHealImages[math.random(1,ComixHolyHealImagesCt)]
    end     

  elseif strfind(DmgLine, getglobal("comix_"..comix_loca.."_fire")) then
    Comix_HealorDmg = false
    return ComixFireImages[math.random(1,ComixFireImagesCt)]
       
  elseif  strfind(DmgLine, getglobal("comix_"..comix_loca.."_frost")) then
    Comix_HealorDmg = false
    return ComixFrostImages[math.random(1,ComixFrostImagesCt)]
    
  elseif strfind(DmgLine, getglobal("comix_"..comix_loca.."_shadow")) then
    Comix_HealorDmg = false
    return ComixShadowImages[math.random(1,ComixShadowImagesCt)]

  elseif strfind(DmgLine, getglobal("comix_"..comix_loca.."_nature")) then
    Comix_HealorDmg = false
    return ComixNatureImages[math.random(1,ComixNatureImagesCt)]

  elseif strfind(DmgLine, getglobal("comix_"..comix_loca.."_arcane")) then
    Comix_HealorDmg = false
    return ComixArcaneImages[math.random(1,ComixArcaneImagesCt)]

  elseif strfind(DmgLine, getglobal("comix_"..comix_loca.."_holy")) then
    Comix_HealorDmg = false
    return ComixHolyDmgImages[math.random(1,ComixHolyDmgImagesCt)]

  else 
    Comix_HealorDmg = false
    return ComixImages[math.random(1,ComixImagesCt)]
  
  end
end        

