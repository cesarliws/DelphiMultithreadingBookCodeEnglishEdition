object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 10.3: Simulations and Intensive Dat' +
    'a Calculations in Parallel'
  ClientHeight = 526
  ClientWidth = 584
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
    584
    526)
  TextHeight = 15
  object ImageDisplay: TImage
    Left = 8
    Top = 39
    Width = 568
    Height = 347
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
  object GenerateSequentialButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Generate Sequentially'
    TabOrder = 0
    OnClick = GenerateSequentialButtonClick
  end
  object GenerateParallelButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Generate in Parallel'
    TabOrder = 1
    OnClick = GenerateParallelButtonClick
  end
  object CancelButton: TButton
    Left = 390
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Cancel'
    Enabled = False
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 507
    Width = 584
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object LogMemo: TMemo
    Left = 8
    Top = 401
    Width = 568
    Height = 100
    Anchors = [akLeft, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 3
  end
end
