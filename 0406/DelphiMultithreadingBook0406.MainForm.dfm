object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Delphi Multithreading Book - 4.6: Retry Strategies in Threads'
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
  object StartThreadWithRetryButton: TButton
    Left = 8
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Start Thread with Retry'
    TabOrder = 0
    OnClick = StartThreadWithRetryButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
  object RunUntilFailureCheckBox: TCheckBox
    Left = 159
    Top = 12
    Width = 138
    Height = 17
    Caption = 'Run until Failure'
    TabOrder = 1
  end
end
