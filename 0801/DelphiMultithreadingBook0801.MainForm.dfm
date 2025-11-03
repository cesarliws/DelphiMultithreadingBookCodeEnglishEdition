object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 8.1: Code Organization (Threads in ' +
    'Separate Units)'
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
  DesignSize = (
    624
    441)
  TextHeight = 15
  object StartCalculationButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Start Calculation'
    TabOrder = 0
    OnClick = StartCalculationButtonClick
  end
  object CancelCalculationButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Cancel Calculation'
    TabOrder = 1
    OnClick = CancelCalculationButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
  end
  object ProgressBar: TProgressBar
    Left = 390
    Top = 8
    Width = 226
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
end
