object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 3.1: TCriticalSection - A Deeper Lo' +
    'ok at Simple Mutual Exclusion'
  ClientHeight = 441
  ClientWidth = 667
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
    667
    441)
  TextHeight = 15
  object StartThreadsWithCriticalSectionButton: TButton
    Left = 8
    Top = 8
    Width = 249
    Height = 25
    Caption = 'Start Threads with Critical Section'
    TabOrder = 0
    OnClick = StartThreadsWithCriticalSectionButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 651
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
end
