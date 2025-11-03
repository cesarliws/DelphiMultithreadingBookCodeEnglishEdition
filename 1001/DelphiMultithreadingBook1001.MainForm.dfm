object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 10.1: Parallel Processing of Multip' +
    'le Files in Batches'
  ClientHeight = 441
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    630
    441)
  TextHeight = 15
  object GenerateLogFilesButton: TButton
    Left = 8
    Top = 8
    Width = 200
    Height = 25
    Caption = 'Generate Sample Log Files'
    TabOrder = 0
    OnClick = GenerateLogFilesButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 70
    Width = 614
    Height = 363
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object ProcessFilesButton: TButton
    Left = 214
    Top = 8
    Width = 200
    Height = 25
    Caption = 'Process Files in Parallel'
    TabOrder = 1
    OnClick = ProcessFilesButtonClick
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 39
    Width = 614
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object CancelButton: TButton
    Left = 420
    Top = 8
    Width = 200
    Height = 25
    Caption = 'Cancel'
    Enabled = False
    TabOrder = 2
    OnClick = CancelButtonClick
  end
end
