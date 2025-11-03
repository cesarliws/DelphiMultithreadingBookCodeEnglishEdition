object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 
    'Delphi Multithreading Book - 6.3: TParallel.For - Parallelizing ' +
    'Loops'
  ClientHeight = 441
  ClientWidth = 583
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
    583
    441)
  TextHeight = 15
  object CalculatePrimesSequentiallyButton: TButton
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Calculate Primes (Sequentially)'
    TabOrder = 0
    OnClick = CalculatePrimesSequentiallyButtonClick
  end
  object CalculatePrimesInParallelButton: TButton
    Left = 199
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Calculate Primes (In Parallel)'
    TabOrder = 1
    OnClick = CalculatePrimesInParallelButtonClick
  end
  object StopParallelCalculationButton: TButton
    Left = 390
    Top = 8
    Width = 185
    Height = 25
    Caption = 'Stop Calculation (Parallel)'
    TabOrder = 2
    OnClick = StopParallelCalculationButtonClick
  end
  object StopAfterCheckBox: TCheckBox
    Left = 199
    Top = 42
    Width = 234
    Height = 17
    Caption = 'Stop automatically after X primes'
    TabOrder = 3
  end
  object StopAfterSpinEdit: TSpinEdit
    Left = 432
    Top = 39
    Width = 143
    Height = 24
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 100000
  end
  object LogMemo: TMemo
    Left = 8
    Top = 69
    Width = 567
    Height = 364
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
  end
end
