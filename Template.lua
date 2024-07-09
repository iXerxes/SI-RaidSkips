
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- ##
-- ## This file contains a single template preset, for a raid skip
-- ## progress display, used in Progress.lua for SavedInstances.
-- ##
-- ## The only lines that need to change per skip are:
-- ##  - The preset ID
-- ##  - The skip quest IDs
-- ##  - The name for the SI pop-out display (SKIP: Blackrock Foundry)
-- ##  - The name for the tooltip display (Blackrock Foundry)
-- ##
----------------------------------------------------------------------------
----------------------------------------------------------------------------



local presets = {

-- Raid Skip: Blackrock Foundry
["raidskip-blackrock-fountry"] = {
    ["type"] = "custom",
    ["index"] = 50,
    ["name"] = "SKIP: Blackrock Foundry",
    ["reset"] = "none",
  
    ["func"] = function(store, entry)
      wipe(store);
  
      store.questIds = {
        [1] = { norm = 37029, hero = 37030, myth = 37031 }, -- Upper
        -- [2] = nil -- Lower
      };
      store.progress = {}; -- {upper|lower}.{difficulty} = boolean|table
  
      -- Loop through each level (upper/lower) and store the progress of each difficulty.
      for lvl, diffs in ipairs(store.questIds) do
  
        store.progress[lvl] = C_QuestLog.IsQuestFlaggedCompleted(diffs.myth) or {}; -- Unlocking a skip unlocks for all difficulties below.
        if (store.progress[lvl] ~= true) then
          store.progress[lvl].myth = { id = diffs.myth };
          store.progress[lvl].hero = C_QuestLog.IsQuestFlaggedCompleted(diffs.hero) or { id = diffs.hero };
          store.progress[lvl].norm = C_QuestLog.IsQuestFlaggedCompleted(diffs.hero) or (C_QuestLog.IsQuestFlaggedCompleted(diffs.norm) or { id = diffs.norm });
  
          for diff, id in pairs(diffs) do
            if (type(store.progress[lvl][diff]) == 'table') then
              local objectives, fulfilled, required = C_QuestLog.GetQuestObjectives(id), 0, 0;
  
              if (objectives) then
                store.progress[lvl][diff].objectiveSummaryStr = {};
                for i = 1, #objectives, 1 do
                  fulfilled = fulfilled + objectives[i].numFulfilled;
                  required = required + objectives[i].numRequired;
                  store.progress[lvl][diff].objectiveSummaryStr[i] = format("%s/%s", objectives[i].numFulfilled, objectives[i].numRequired);
                end
                store.progress[lvl][diff].summaryStr = format("%s/%s", fulfilled, required);
                store.progress[lvl][diff].summaryFul = fulfilled;
                store.progress[lvl][diff].summaryReq = required;
              else
                store.progress[lvl][diff].summaryStr = "?/?"; -- If the quest isn't cached and needs to be queried, provide some fallback.
              end
  
            end;
          end;
  
        end;
  
      end;
  
    end,
  
    ["showFunc"] = function(store, entry)
      if (not store) then return end;
  
      -- All skips for this raid have been unlocked.
      if (store.progress[1] == true and (store.progress[2] == nil or store.progress[2] == true)) then return SI.questCheckMark end;
  
      local notStartedIcon, lesserCompletedIcon, display = "\124A:UI-LFG-DeclineMark:14:14\124a", "\124A:FlightPath:14:14\124a", "";
  
      -- Loop through each level (upper/lower) and build the display string.
      for lvl, diffs in ipairs(store.progress) do
        if (store.progress[lvl] == true) then
          display = display .. SI.questCheckMark;
        else
          
          -- A difficulty lower than Mythic, but not Mythic has been unlocked.
          if ((store.progress[lvl].norm == true or store.progress[lvl].hero == true) and store.progress[lvl].myth ~= true) then display = display..lesserCompletedIcon.." " end;
  
          -- Display only the highest difficulty with progress.
          local highest = -1; -- 0 = Normal; 1 = Heroic; 2 = Mythic
          highest = (diffs.norm ~= true and diffs.norm.summaryFul > 0) and 0 or highest;
          highest = (diffs.hero ~= true and diffs.hero.summaryFul > 0) and 1 or highest;
          highest = (diffs.myth ~= true and diffs.myth.summaryFul > 0) and 2 or highest;
  
          if (highest == 0) then display = display..format("%s%s", ITEM_STANDARD_COLOR_CODE, diffs.norm.summaryStr); end;
          if (highest == 1) then display = display..format("%s%s", ITEM_SUPERIOR_COLOR_CODE, diffs.hero.summaryStr) end;
          if (highest == 2) then display = display..format("%s%s", ITEM_EPIC_COLOR_CODE, diffs.myth.summaryStr) end;
  
          if (highest == -1) then display = display..notStartedIcon end;
  
        end;
        if (#store.progress > 1) then display = display .. '\n' end;
      end;
  
      return display;
    end,
  
    ["tooltipFunc"] = function(store, entry, toon)
      local indentStr, tip = "  ", Tooltip:AcquireIndicatorTip(2, 'LEFT', 'RIGHT');
      tip:AddHeader(SI:ClassColorToon(toon), "Blackrock Foundry");
      tip:AddLine(" ");
  
      for lvl, diffs in ipairs(store.progress) do
        if (#store.progress > 1) then tip:AddLine( (lvl == 1) and "\124A:Garr_LevelBadge_1:25:25\124a" or "\124A:Garr_LevelBadge_2:25:25\124a") end;
  
        if (store.progress[lvl] == true) then
          tip:AddLine(ITEM_STANDARD_COLOR_CODE..PLAYER_DIFFICULTY1, SI.questCheckMark);
          tip:AddLine(ITEM_SUPERIOR_COLOR_CODE..PLAYER_DIFFICULTY2, SI.questCheckMark);
          tip:AddLine(ITEM_EPIC_COLOR_CODE..PLAYER_DIFFICULTY6, SI.questCheckMark);
  
        else
          local orderedDiffs, diffColors, diffNames = { [1] = diffs.norm, [2] = diffs.hero, [3] = diffs.myth }, { [1] = ITEM_STANDARD_COLOR_CODE, [2] = ITEM_SUPERIOR_COLOR_CODE, [3] = ITEM_EPIC_COLOR_CODE }, { [1] = PLAYER_DIFFICULTY1, [2] = PLAYER_DIFFICULTY2, [3] = PLAYER_DIFFICULTY6 };
          for i, diff in ipairs(orderedDiffs) do
            if (diff == true) then 
              tip:AddLine(diffNames[i], SI.questCheckMark);
            else
  
              tip:AddLine(diffColors[i]..diffNames[i], diffColors[i]..diff.summaryStr);
              local objectives = C_QuestLog.GetQuestObjectives(diff.id);
              for i = 1, #objectives, 1 do
                local text = objectives[i].text;
                local prog = string.match(text, "%d/%d");
                tip:AddLine(indentStr..text:gsub(prog, ""), diff.objectiveSummaryStr[i]..indentStr);
              end
  
            end
          end
        end;
  
        if (#store.progress > 1) then tip:AddLine('\n') end;
      end;
  
      tip:Show();
    end,
  
    ["persists"] = true,
  },

}