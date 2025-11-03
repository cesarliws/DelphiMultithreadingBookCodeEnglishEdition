object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 3.3: TMutex - Synchronization Betwe' +
    'en Processes'
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
  object LogMemo: TMemo
    Left = 8
    Top = 8
    Width = 608
    Height = 425
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
end
