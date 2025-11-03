object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 6.6: Other PPL Features: TParallelA' +
    'rray'
  ClientHeight = 441
  ClientWidth = 732
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
    732
    441)
  TextHeight = 15
  object SortArraySequentialButton: TButton
    Left = 8
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Sort Array (Sequential)'
    TabOrder = 0
    OnClick = SortArraySequentialButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 39
    Width = 718
    Height = 394
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
  object SortArrayParallelButton: TButton
    Left = 189
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Sort Array (Parallel)'
    TabOrder = 2
    OnClick = SortArrayParallelButtonClick
  end
  object ProcessArraySequentialButton: TButton
    Left = 370
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Process Array (Sequential)'
    TabOrder = 3
    OnClick = ProcessArraySequentialButtonClick
  end
  object ProcessArrayParallelButton: TButton
    Left = 551
    Top = 8
    Width = 175
    Height = 25
    Caption = 'Process Array (Parallel)'
    TabOrder = 4
    OnClick = ProcessArrayParallelButtonClick
  end
end
