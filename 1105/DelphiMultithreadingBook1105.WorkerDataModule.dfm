object WorkerDM: TWorkerDM
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object FDConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Demo_Pooled')
    LoginPrompt = False
    Left = 72
    Top = 32
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 72
    Top = 88
  end
end
