object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 7.4: Advanced PPL Management: `TThr' +
    'eadPool` and `TThreadPoolStats`'
  ClientHeight = 441
  ClientWidth = 748
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    748
    441)
  TextHeight = 15
  object StatsLabel: TLabel
    Left = 8
    Top = 39
    Width = 84
    Height = 15
    Caption = 'Pool Statistics: -'
  end
  object StartDefaultPoolButton: TButton
    Left = 8
    Top = 8
    Width = 240
    Height = 25
    Caption = 'Process with Default Pool'
    TabOrder = 0
    OnClick = StartDefaultPoolButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 60
    Width = 732
    Height = 373
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
  end
  object StartCustomPoolButton: TButton
    Left = 254
    Top = 8
    Width = 240
    Height = 25
    Caption = 'Process with Custom Pool (Max 5)'
    TabOrder = 1
    OnClick = StartCustomPoolButtonClick
  end
  object CancelButton: TButton
    Left = 500
    Top = 8
    Width = 240
    Height = 25
    Caption = 'Cancel Processing'
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object StatsTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = StatsTimerTimer
    Left = 32
    Top = 136
  end
end
