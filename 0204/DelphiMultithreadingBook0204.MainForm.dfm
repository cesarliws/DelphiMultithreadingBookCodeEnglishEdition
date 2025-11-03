object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 2.4: Anonymous Threads (TThread.Cre' +
    'ateAnonymousThread)'
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
  object StartAnonymousMethodButton: TButton
    Left = 8
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Start Anonymous Method'
    TabOrder = 0
    OnClick = StartAnonymousMethodButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object StartAnonymousThreadButton: TButton
    Left = 189
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Start Anonymous Thread'
    TabOrder = 2
    OnClick = StartAnonymousThreadButtonClick
  end
  object StopAnonymousThreadButton: TButton
    Left = 370
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Stop Anonymous Thread'
    TabOrder = 3
    OnClick = StopAnonymousThreadButtonClick
  end
end
