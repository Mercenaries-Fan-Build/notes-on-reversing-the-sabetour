if KillDierkerDebug == nil then
  KillDierkerDebug = SabTaskObjective:Create()
  KillDierkerDebug:Configure({
    TaskCount = "auto",
    bStarterless = true,
    sSaveMissionNameID = "MissionNames_Text.A3M2",
    tSMEDNodes = {},
    tStaticTags = {}
  })
end

function KillDierkerDebug:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_TowerCinematic(self)
end

function KillDierkerDebug:GENERAL_Setup()
end

function KillDierkerDebug:Task_TowerCinematic()
  self:CreateTask({
    sName = "Task_TowerCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "411_CinA_Tower-DierkerStart",
    tCinematicNodes = {
      "Missions\\cinematics\\411_cina_tower"
    },
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_KillDierker,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_TowerCinematic",
          true
        }
      }
    },
    tCinematicNodes = {
      "411_cina_tower"
    }
  })
end

function KillDierkerDebug:Task_KillDierker()
  self:CreateTask({
    sName = "Task_KillDierker",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = {
      "Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker"
    },
    sObjectiveTextID = "A3M2_Text.KillDierker",
    bNoWorldBlip = true,
    bNoHUDBlip = true,
    tOnActivate = {
      {
        Render.FadeScreen,
        {false}
      },
      {
        self.RunDierkerCam,
        {self}
      },
      {
        self.DelaytoStartDierkerLoop,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_DierkerKilledCine,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_3\\mission_2\\dierker",
      "Missions\\act_3\\mission_2\\DierkerGun"
    }
  })
end

function KillDierkerDebug:RunDierkerCam()
  local hPistol = Handle("Missions\\act_3\\mission_2\\dierker\\WP_PS_DierkerGun")
  local hDierkerKill = Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker")
  self.hDierkerKill = hDierkerKill
  Actor.EnterSpecialKillMode(Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker"), hPistol, 18)
  Actor.PlayAnimation(hDierkerKill, "Dierker_Final", -1, false, nil, "Act_3_Mission_2.DeirkerSuicide", self, nil, false, nil, true)
end

function KillDierkerDebug:DeirkerSuicide()
  Object.Kill(self.hDierkerKill)
end

function KillDierkerDebug:DelaytoStartDierkerLoop()
  EVENT_Timer("KillDierkerDebug.StartDierkerConvoLoop", self, 3)
end

function KillDierkerDebug:StartDierkerConvoLoop()
  if Object.IsAlive(Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker")) == true then
    Cin.PlayConversation("A3M2_DierkerTaunt_Armed")
    EVENT_Timer("KillDierkerDebug.PlayNextLoop", self, 7)
  else
  end
end

function KillDierkerDebug:PlayNextLoop()
  if Object.IsAlive(Handle("Missions\\act_3\\mission_2\\dierker\\CH_NZ_Dierker")) == true then
    Cin.PlayConversation("A3M2_DierkerTaunt_Armed")
  else
  end
end

function KillDierkerDebug:Task_DierkerKilledCine()
  self:CreateTask({
    sName = "Task_DierkerKilledCine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "411_CinA_Tower-DierkerKilled",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_CineWTFFinal,
        {self}
      }
    },
    tCinematicNodes = {},
    tSMEDNodes = {
      "Missions\\cinematics\\412_cinb_dierkerdead"
    }
  })
end

function KillDierkerDebug:TASK_CineWTFFinal()
  self:CreateTask({
    sName = "TASK_CineWTFFinal",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_Dierker",
    tOnActivate = {},
    tOnComplete = {},
    tSMEDNodes = {},
    tCinematicNodes = {
      "wtf_act4_dierker"
    }
  })
end
