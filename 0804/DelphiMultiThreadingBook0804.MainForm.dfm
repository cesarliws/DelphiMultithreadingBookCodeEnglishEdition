object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 8.4: Preventing Common Problems: De' +
    'adlocks and Race Conditions'
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
  object StartDeadlockExampleButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Start Deadlock (Example)'
    TabOrder = 0
    OnClick = StartDeadlockExampleButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object StartDeadlockPreventionButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Start Deadlock (Prevention)'
    TabOrder = 2
    OnClick = StartDeadlockPreventionButtonClick
  end
end
