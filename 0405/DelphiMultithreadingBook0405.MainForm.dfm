object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Delphi Multithreading Book - 4.5: Exception Handling in Threads'
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
  object RunThreadWithExceptionButton: TButton
    Left = 8
    Top = 8
    Width = 200
    Height = 25
    Caption = 'Run Thread with Exception'
    TabOrder = 0
    OnClick = RunThreadWithExceptionButtonClick
  end
  object RunThreadWithErrorButton: TButton
    Left = 214
    Top = 8
    Width = 200
    Height = 25
    Caption = 'Run Thread with Error'
    TabOrder = 1
    OnClick = RunThreadWithErrorButtonClick
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
