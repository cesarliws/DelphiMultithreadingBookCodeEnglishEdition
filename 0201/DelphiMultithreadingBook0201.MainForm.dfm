object MainForm: TMainForm
  Left = 551
  Top = 83
  Caption = 
    'Delphi Multithreading Book - 2.1: Creating and Managing Simple T' +
    'hreads'
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
    Width = 249
    Height = 25
    Caption = 'Start Thread'
    TabOrder = 0
    OnClick = StartThreadButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 72
    Width = 608
    Height = 361
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object StopThreadButton: TButton
    Left = 263
    Top = 8
    Width = 249
    Height = 25
    Caption = 'Stop Thread'
    TabOrder = 2
    OnClick = StopThreadButtonClick
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 39
    Width = 608
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
end
