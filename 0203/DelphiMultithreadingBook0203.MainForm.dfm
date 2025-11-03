object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 2.3: Dealing with Multiple Threads ' +
    'and Shared Data (Introduction to Synchronization)'
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
  object StartWithoutSyncButton: TButton
    Left = 8
    Top = 8
    Width = 249
    Height = 25
    Caption = 'Start without Synchronization'
    TabOrder = 0
    OnClick = StartWithoutSyncButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object StartWithSyncButton: TButton
    Left = 263
    Top = 8
    Width = 249
    Height = 25
    Caption = 'Start with Synchronization'
    TabOrder = 2
    OnClick = StartWithSyncButtonClick
  end
end
