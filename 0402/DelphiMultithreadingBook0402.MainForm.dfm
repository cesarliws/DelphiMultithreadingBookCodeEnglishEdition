object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 4.2: Graceful Thread Cancellation (' +
    '`Terminate` and `WaitFor`)'
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
  object StartThreadButton: TButton
    Left = 8
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Start Thread'
    TabOrder = 0
    OnClick = StartThreadButtonClick
  end
  object StopThreadButton: TButton
    Left = 159
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Stop Thread'
    TabOrder = 1
    OnClick = StopThreadButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
end
