object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 5.4: Asynchronous Execution Pattern' +
    ' on the Main Thread: The TMainThreadDispatcher'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    624
    441)
  TextHeight = 15
  object StartWorkerButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Start Processing Thread'
    TabOrder = 0
    OnClick = StartWorkerButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
  object LoadDataButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Load Data (Async)'
    TabOrder = 1
    OnClick = LoadDataButtonClick
  end
end
