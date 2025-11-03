object OrderForm: TOrderForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Order'
  ClientHeight = 419
  ClientWidth = 499
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object ButtonsPanel: TPanel
    Left = 0
    Top = 386
    Width = 499
    Height = 33
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 1
    object SaveButton: TButton
      AlignWithMargins = True
      Left = 421
      Top = 3
      Width = 75
      Height = 25
      Align = alRight
      Caption = 'Save'
      TabOrder = 0
      OnClick = SaveButtonClick
    end
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 340
      Top = 3
      Width = 75
      Height = 25
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = CancelButtonClick
    end
  end
  object ControlsPanel: TPanel
    Left = 0
    Top = 0
    Width = 499
    Height = 386
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object OrderInfoGroupBox: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 493
      Height = 153
      Align = alTop
      Caption = 'Order Information'
      TabOrder = 0
      object FreightLabel: TLabel
        Left = 264
        Top = 111
        Width = 40
        Height = 15
        Caption = 'Freight:'
      end
      object ShipViaLabel: TLabel
        Left = 264
        Top = 82
        Width = 45
        Height = 15
        Caption = 'Ship Via:'
      end
      object ShippedDateLabel: TLabel
        Left = 264
        Top = 53
        Width = 73
        Height = 15
        Caption = 'Shipped Date:'
      end
      object RequiredDateLabel: TLabel
        Left = 264
        Top = 24
        Width = 77
        Height = 15
        Caption = 'Required Date:'
      end
      object OrderDateLabel: TLabel
        Left = 16
        Top = 111
        Width = 60
        Height = 15
        Caption = 'Order Date:'
      end
      object EmployeeIDLabel: TLabel
        Left = 16
        Top = 82
        Width = 69
        Height = 15
        Caption = 'Employee ID:'
      end
      object CustomerIDLabel: TLabel
        Left = 16
        Top = 53
        Width = 69
        Height = 15
        Caption = 'Customer ID:'
      end
      object OrderIDLabel: TLabel
        Left = 16
        Top = 24
        Width = 47
        Height = 15
        Caption = 'Order ID:'
      end
      object OrderIDEdit: TEdit
        Left = 112
        Top = 20
        Width = 121
        Height = 23
        ReadOnly = True
        TabOrder = 0
      end
      object FreightEdit: TMaskEdit
        Left = 360
        Top = 107
        Width = 121
        Height = 23
        TabOrder = 7
        Text = '0.00'
      end
      object ShipViaEdit: TEdit
        Left = 360
        Top = 78
        Width = 121
        Height = 23
        NumbersOnly = True
        TabOrder = 6
        Text = '1'
      end
      object ShippedDateDateTimePicker: TDateTimePicker
        Left = 360
        Top = 49
        Width = 121
        Height = 23
        Date = 44867.000000000000000000
        Time = 44867.000000000000000000
        TabOrder = 5
      end
      object RequiredDateDateTimePicker: TDateTimePicker
        Left = 360
        Top = 20
        Width = 121
        Height = 23
        Date = 44867.000000000000000000
        Time = 44867.000000000000000000
        TabOrder = 4
      end
      object OrderDateDateTimePicker: TDateTimePicker
        Left = 112
        Top = 107
        Width = 121
        Height = 23
        Date = 44867.000000000000000000
        Time = 44867.000000000000000000
        TabOrder = 3
      end
      object EmployeeIdEdit: TEdit
        Left = 112
        Top = 78
        Width = 121
        Height = 23
        ReadOnly = True
        TabOrder = 2
      end
      object CustomerIdEdit: TEdit
        Left = 112
        Top = 49
        Width = 121
        Height = 23
        ReadOnly = True
        TabOrder = 1
      end
    end
    object DeliveryInfoGroupBox: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 162
      Width = 493
      Height = 218
      Align = alTop
      Caption = 'Shipping Information'
      TabOrder = 1
      object ShipNameLabel: TLabel
        Left = 16
        Top = 24
        Width = 61
        Height = 15
        Caption = 'Ship Name:'
      end
      object ShipAddressLabel: TLabel
        Left = 16
        Top = 56
        Width = 71
        Height = 15
        Caption = 'Ship Address:'
      end
      object ShipCityLabel: TLabel
        Left = 16
        Top = 88
        Width = 50
        Height = 15
        Caption = 'Ship City:'
      end
      object ShipRegionLabel: TLabel
        Left = 16
        Top = 120
        Width = 66
        Height = 15
        Caption = 'Ship Region:'
      end
      object ShipPostalCodeLabel: TLabel
        Left = 16
        Top = 152
        Width = 92
        Height = 15
        Caption = 'Ship Postal Code:'
      end
      object ShipCountryLabel: TLabel
        Left = 16
        Top = 184
        Width = 72
        Height = 15
        Caption = 'Ship Country:'
      end
      object ShipNameEdit: TEdit
        Left = 112
        Top = 21
        Width = 369
        Height = 23
        TabOrder = 0
      end
      object ShipAddressEdit: TEdit
        Left = 112
        Top = 53
        Width = 369
        Height = 23
        TabOrder = 1
      end
      object ShipCityEdit: TEdit
        Left = 112
        Top = 85
        Width = 200
        Height = 23
        TabOrder = 2
      end
      object ShipRegionEdit: TEdit
        Left = 112
        Top = 117
        Width = 200
        Height = 23
        TabOrder = 3
      end
      object ShipPostalCodeEdit: TEdit
        Left = 112
        Top = 149
        Width = 121
        Height = 23
        TabOrder = 4
      end
      object ShipCountryEdit: TEdit
        Left = 112
        Top = 181
        Width = 121
        Height = 23
        TabOrder = 5
      end
    end
  end
end
