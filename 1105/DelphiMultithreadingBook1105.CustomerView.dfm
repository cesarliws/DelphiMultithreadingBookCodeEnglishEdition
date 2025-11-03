object CustomerForm: TCustomerForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Customer'
  ClientHeight = 454
  ClientWidth = 487
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
    Top = 421
    Width = 487
    Height = 33
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 1
    object SaveButton: TButton
      AlignWithMargins = True
      Left = 409
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
      Left = 328
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
    Width = 487
    Height = 421
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object CustomerInfoGroupBox: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 481
      Height = 415
      Align = alClient
      Caption = 'Customer Information'
      TabOrder = 0
      object CustomerIDLabel: TLabel
        Left = 16
        Top = 32
        Width = 69
        Height = 15
        Caption = 'Customer ID:'
      end
      object CompanyNameLabel: TLabel
        Left = 16
        Top = 64
        Width = 90
        Height = 15
        Caption = 'Company Name:'
      end
      object ContactNameLabel: TLabel
        Left = 16
        Top = 96
        Width = 80
        Height = 15
        Caption = 'Contact Name:'
      end
      object ContactTitleLabel: TLabel
        Left = 16
        Top = 128
        Width = 71
        Height = 15
        Caption = 'Contact Title:'
      end
      object AddressLabel: TLabel
        Left = 16
        Top = 160
        Width = 45
        Height = 15
        Caption = 'Address:'
      end
      object CityLabel: TLabel
        Left = 16
        Top = 224
        Width = 24
        Height = 15
        Caption = 'City:'
      end
      object RegionLabel: TLabel
        Left = 16
        Top = 256
        Width = 40
        Height = 15
        Caption = 'Region:'
      end
      object PostalCodeLabel: TLabel
        Left = 16
        Top = 288
        Width = 66
        Height = 15
        Caption = 'Postal Code:'
      end
      object CountryLabel: TLabel
        Left = 16
        Top = 320
        Width = 46
        Height = 15
        Caption = 'Country:'
      end
      object PhoneLabel: TLabel
        Left = 16
        Top = 352
        Width = 37
        Height = 15
        Caption = 'Phone:'
      end
      object FaxLabel: TLabel
        Left = 16
        Top = 384
        Width = 20
        Height = 15
        Caption = 'Fax:'
      end
      object CustomerIDEdit: TEdit
        Left = 120
        Top = 29
        Width = 121
        Height = 23
        TabOrder = 0
      end
      object CompanyNameEdit: TEdit
        Left = 120
        Top = 61
        Width = 345
        Height = 23
        TabOrder = 1
      end
      object ContactNameEdit: TEdit
        Left = 120
        Top = 93
        Width = 345
        Height = 23
        TabOrder = 2
      end
      object ContactTitleEdit: TEdit
        Left = 120
        Top = 125
        Width = 345
        Height = 23
        TabOrder = 3
      end
      object AddressEdit: TEdit
        Left = 120
        Top = 157
        Width = 345
        Height = 55
        AutoSize = False
        TabOrder = 4
      end
      object CityEdit: TEdit
        Left = 120
        Top = 221
        Width = 200
        Height = 23
        TabOrder = 5
      end
      object RegionEdit: TEdit
        Left = 120
        Top = 253
        Width = 200
        Height = 23
        TabOrder = 6
      end
      object PostalCodeEdit: TEdit
        Left = 120
        Top = 285
        Width = 121
        Height = 23
        TabOrder = 7
      end
      object CountryEdit: TEdit
        Left = 120
        Top = 317
        Width = 121
        Height = 23
        TabOrder = 8
      end
      object PhoneEdit: TEdit
        Left = 120
        Top = 349
        Width = 121
        Height = 23
        TabOrder = 9
      end
      object FaxEdit: TEdit
        Left = 120
        Top = 381
        Width = 121
        Height = 23
        TabOrder = 10
      end
    end
  end
end
