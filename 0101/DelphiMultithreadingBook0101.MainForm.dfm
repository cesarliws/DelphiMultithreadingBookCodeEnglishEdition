object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Delphi Multithreading Book - 1.1 - The UI Freeze Problem'
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
  DesignSize = (
    624
    441)
  TextHeight = 15
  object StartSynchronousProcessingButton: TButton
    Left = 8
    Top = 8
    Width = 249
    Height = 25
    Caption = 'Start Synchronous Processing'
    TabOrder = 0
    OnClick = StartSynchronousProcessingButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
end
