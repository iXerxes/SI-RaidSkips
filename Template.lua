["raidskip-sepulcher"] = {
    ["type"] = "custom",
    -- ["expansion"] = 9,
    ["index"] = 58,
    ["name"] = "SKIP: Sepulcher of the First Ones",
    ["reset"] = "none",


    ["func"] = function(store, entry)
      wipe(store);

      store.colors = {
        norm = "|cFFFFFFFF%s|r",
        hero = "|cFF0070DD%s|r",
        myth = "|cFFA335EE%s|r",
      };
      store.questIDs = {
        upper = { norm = 65764, hero = 65763, myth = 65762 },
        -- lower = nil
      };
      store.progress = {}; -- {upper|lower}.{difficulty} = boolean|table

      store.progress.upper = C_QuestLog.IsQuestFlaggedCompleted(store.questIDs.upper.myth) or {}; -- Unlocking a skip unlocks for all difficulties below.
      if (store.progress.upper ~= true) then
        store.progress.upper.myth = {};
        store.progress.upper.hero = C_QuestLog.IsQuestFlaggedCompleted(store.questIDs.upper.hero) or {};
        store.progress.upper.norm = C_QuestLog.IsQuestFlaggedCompleted(store.questIDs.upper.hero) or (C_QuestLog.IsQuestFlaggedCompleted(store.questIDs.upper.norm) or {});

        for diff,id in pairs(store.questIDs.upper) do
          if (type(store.progress.upper[diff]) == 'table') then
            local objectives, fulfilled, required = C_QuestLog.GetQuestObjectives(id), 0, 0;

            if (objectives) then
              store.progress.upper[diff].objectiveSummary = {};
              for i = 1, #objectives, 1 do
                fulfilled = fulfilled + objectives[i].numFulfilled;
                required = required + objectives[i].numRequired;
                store.progress.upper[diff].objectiveSummary[i] = format("%s/%s", objectives[i].numFulfilled, objectives[i].numRequired);
              end
              store.progress.upper[diff].summary = format("%s/%s", fulfilled, required);
            else
              store.progress.upper[diff].summary = "?/?"; -- If the quest isn't cached and needs to be queried, provide some fallback.
            end
          end
        end
      end
    end,

    ["showFunc"] = function(store, entry)

      if (not store) then return end;

      if (store.progress.upper == true and (store.progress.lower == nil or store.progress.lower == true)) then
        return SI.questCheckMark;
      else

        local display = "";

        if (store.progress.upper == true) then
          display = SI.questCheckMark;
        else
          display = format("%s %s %s",
          store.progress.upper['norm'] == true and SI.questCheckMark or format(store.colors.norm, store.progress.upper['norm'].summary),
          store.progress.upper['hero'] == true and SI.questCheckMark or format(store.colors.hero, store.progress.upper['hero'].summary),
          store.progress.upper['myth'] == true and SI.questCheckMark or format(store.colors.myth, store.progress.upper['myth'].summary)
        );
        end

        return display;

      end

    end,

    ["resetFunc"] = function(store, entry) end,

    ["tooltipFunc"] = function(store, entry, toon)
      local tip = Tooltip:AcquireIndicatorTip(2, 'LEFT', 'RIGHT');
      tip:AddHeader(SI:ClassColorToon(toon), "Sepulcher of the First Ones");
      tip:AddLine(" ");

      if (store.progress.upper == true) then
        tip:AddLine(format(store.colors.norm, PLAYER_DIFFICULTY1 ), SI.questCheckMark);
        tip:AddLine(format(store.colors.hero, PLAYER_DIFFICULTY2 ), SI.questCheckMark);
        tip:AddLine(format(store.colors.myth, PLAYER_DIFFICULTY6 ), SI.questCheckMark);

      elseif (store.progress.upper.hero == true) then
        tip:AddLine(format(store.colors.norm, PLAYER_DIFFICULTY1 ), SI.questCheckMark);
        tip:AddLine(" ");
        tip:AddLine(format(store.colors.hero, PLAYER_DIFFICULTY2 ), SI.questCheckMark);
        tip:AddLine(" ");
        tip:AddLine(format(store.colors.myth, PLAYER_DIFFICULTY6 ), store.progress.upper.myth.summary);

        local objectives = C_QuestLog.GetQuestObjectives(store.questIDs.upper.myth);
        for i = 1, #objectives, 1 do
          local text = objectives[i].text;
          local prog = string.match(text, "%d/%d");
          tip:AddLine("  "..text:gsub(prog .. " ", ""), store.progress.upper.myth.objectiveSummary[i].."  ");
        end

      elseif (store.progress.upper.norm == true) then

        tip:AddLine(format(store.colors.norm, PLAYER_DIFFICULTY1 ), SI.questCheckMark);
        tip:AddLine(" ");
        tip:AddLine(format(store.colors.hero, PLAYER_DIFFICULTY2 ), store.progress.upper.hero.summary);
        local objectives = C_QuestLog.GetQuestObjectives(store.questIDs.upper.hero);
        for i = 1, #objectives, 1 do
          local text = objectives[i].text;
          local prog = string.match(text, "%d/%d");
          tip:AddLine("  "..text:gsub(prog .. " ", ""), store.progress.upper.hero.objectiveSummary[i].."  ");
        end

        tip:AddLine(" ");

        tip:AddLine(format(store.colors.myth, PLAYER_DIFFICULTY6 ), store.progress.upper.myth.summary);
        local objectives = C_QuestLog.GetQuestObjectives(store.questIDs.upper.myth);
        for i = 1, #objectives, 1 do
          local text = objectives[i].text;
          local prog = string.match(text, "%d/%d");
          tip:AddLine("  "..text:gsub(prog .. " ", ""), store.progress.upper.myth.objectiveSummary[i].."  ");
        end

      else

        tip:AddLine(format(store.colors.norm, PLAYER_DIFFICULTY1 ), store.progress.upper.norm.summary);
        local objectives = C_QuestLog.GetQuestObjectives(store.questIDs.upper.norm);
        for i = 1, #objectives, 1 do
          local text = objectives[i].text;
          local prog = string.match(text, "%d/%d");
          tip:AddLine("  "..text:gsub(prog .. " ", ""), store.progress.upper.norm.objectiveSummary[i].."  ");
        end

        tip:AddLine(" ");

        tip:AddLine(format(store.colors.hero, PLAYER_DIFFICULTY2 ), store.progress.upper.hero.summary);
        local objectives = C_QuestLog.GetQuestObjectives(store.questIDs.upper.hero);
        for i = 1, #objectives, 1 do
          local text = objectives[i].text;
          local prog = string.match(text, "%d/%d");
          tip:AddLine("  "..text:gsub(prog .. " ", ""), store.progress.upper.hero.objectiveSummary[i].."  ");
        end

        tip:AddLine(" ");

        tip:AddLine(format(store.colors.myth, PLAYER_DIFFICULTY6 ), store.progress.upper.myth.summary);
        local objectives = C_QuestLog.GetQuestObjectives(store.questIDs.upper.myth);
        for i = 1, #objectives, 1 do
          local text = objectives[i].text;
          local prog = string.match(text, "%d/%d");
          tip:AddLine("  "..text:gsub(prog .. " ", ""), store.progress.upper.myth.objectiveSummary[i].."  ");
        end

      end

      tip:Show();
    end,
            


    ["questID"] = 1,
    ["fullObjective"] = false,
    ["persists"] = true,
  }