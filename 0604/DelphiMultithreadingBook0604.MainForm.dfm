object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 6.4: Task Coordination: TTask.WaitF' +
    'orAll, TTask.WaitForAny and TParallel.Join'
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
  object WaitForAllButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'WaitForAll'
    TabOrder = 0
    OnClick = WaitForAllButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 608
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
  end
  object WaitForAnyButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'WaitForAny'
    TabOrder = 1
    OnClick = WaitForAnyButtonClick
  end
  object ParallelJoinButton: TButton
    Left = 390
    Top = 8
    Width = 185
    Height = 25
    Caption = 'ParallelJoin'
    TabOrder = 2
    OnClick = ParallelJoinButtonClick
  end
end
