object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 11.2: Essential Practical Example: ' +
    '`TDataModule` in a `TThread`'
  ClientHeight = 472
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
    472)
  TextHeight = 15
  object LoadDataButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Load Data in Thread'
    TabOrder = 0
    OnClick = LoadDataButtonClick
  end
  object CancelButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Cancel'
    Enabled = False
    TabOrder = 1
    OnClick = CancelButtonClick
  end
  object LogMemo: TMemo
    Left = 8
    Top = 368
    Width = 608
    Height = 96
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 2
  end
  object DBGridUI: TDBGrid
    Left = 8
    Top = 39
    Width = 608
    Height = 323
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSourceUI
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object DataSourceUI: TDataSource
    DataSet = FDMemTableUI
    Left = 544
    Top = 8
  end
  object FDMemTableUI: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 456
    Top = 8
  end
  object FDConnectionTemplate: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Demo')
    Left = 456
    Top = 80
  end
end
