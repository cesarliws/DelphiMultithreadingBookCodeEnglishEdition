object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 8.2: Avoiding Concurrency with `thr' +
    'eadvar` (Thread-Local Storage)'
  ClientHeight = 441
  ClientWidth = 624
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
    624
    441)
  TextHeight = 15
  object StartNoSyncButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'No Synchronization (Incorrect)'
    TabOrder = 0
    OnClick = StartNoSyncButtonClick
  end
  object StartCriticalSectionButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'With TCriticalSection (Slow)'
    TabOrder = 1
    OnClick = StartCriticalSectionButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
  end
  object StartThreadVarButton: TButton
    Left = 390
    Top = 8
    Width = 185
    Height = 25
    Caption = 'With threadvar (Optimized)'
    TabOrder = 2
    OnClick = StartThreadVarButtonClick
  end
end
