object ClassViewer: TClassViewer
  Left = 0
  Top = 0
  Caption = 'Class RTTI Inspector'
  ClientHeight = 380
  ClientWidth = 782
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lstHierarchy: TListBox
    Left = 8
    Top = 31
    Width = 225
    Height = 336
    ItemHeight = 13
    ScrollWidth = 110
    TabOrder = 0
    OnClick = lstHierarchyClick
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 8
    Width = 104
    Height = 20
    Caption = 'Class Hierarchy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object PageControl1: TPageControl
    Left = 239
    Top = 8
    Width = 534
    Height = 359
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'General'
      object StaticText4: TStaticText
        Left = 292
        Top = 9
        Width = 82
        Height = 17
        Caption = 'Property Count:'
        TabOrder = 0
      end
      object StaticText5: TStaticText
        Left = 422
        Top = 9
        Width = 82
        Height = 17
        Caption = 'Declared in unit:'
        TabOrder = 1
      end
      object txtPropCount: TEdit
        Left = 293
        Top = 31
        Width = 41
        Height = 21
        ReadOnly = True
        TabOrder = 2
      end
      object txtUnit: TEdit
        Left = 422
        Top = 31
        Width = 82
        Height = 21
        ReadOnly = True
        TabOrder = 3
      end
      object StaticText8: TStaticText
        Left = 3
        Top = 6
        Width = 63
        Height = 17
        Caption = 'Class Name:'
        TabOrder = 4
      end
      object txtClassName: TEdit
        Left = 3
        Top = 31
        Width = 184
        Height = 21
        ReadOnly = True
        TabOrder = 5
      end
      object StaticText9: TStaticText
        Left = 193
        Top = 9
        Width = 72
        Height = 17
        Caption = 'Instance Size:'
        TabOrder = 6
      end
      object txtInstanceSize: TEdit
        Left = 194
        Top = 31
        Width = 36
        Height = 21
        ReadOnly = True
        TabOrder = 7
      end
      object lstVirtuals: TListView
        Left = 3
        Top = 103
        Width = 501
        Height = 226
        Columns = <
          item
            Caption = 'Slot'
            Width = 30
          end
          item
            Caption = 'Address'
            Width = 64
          end
          item
            Caption = 'Class'
            Width = 116
          end
          item
            Caption = 'Name'
            Width = 116
          end>
        TabOrder = 8
        ViewStyle = vsReport
      end
      object StaticText10: TStaticText
        Left = 20
        Top = 80
        Width = 82
        Height = 17
        Caption = 'Virtual methods:'
        TabOrder = 9
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Interfaces'
      ImageIndex = 1
      object lstInterface: TListView
        Left = 3
        Top = 3
        Width = 520
        Height = 325
        Columns = <
          item
            Caption = 'GUID'
            Width = 235
          end
          item
            Caption = 'Table'
            Width = 75
          end
          item
            Caption = 'Offset'
            Width = 43
          end
          item
            Caption = 'ImplGetter'
            Width = 63
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Init Table'
      ImageIndex = 2
      object lstInit: TListView
        Left = 3
        Top = 3
        Width = 520
        Height = 325
        Columns = <
          item
            Caption = 'Name'
            Width = 110
          end
          item
            Caption = 'Type'
            Width = 68
          end
          item
            Caption = 'Offset'
            Width = 43
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Published Fields'
      ImageIndex = 3
      object lstPublishedFields: TListView
        Left = 0
        Top = 3
        Width = 523
        Height = 326
        Columns = <
          item
            Caption = 'Name'
            Width = 116
          end
          item
            Caption = 'Type'
            Width = 74
          end
          item
            Caption = 'Offset'
            Width = 49
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'All RTTI Fields'
      ImageIndex = 4
      object lstFields: TListView
        Left = 0
        Top = 3
        Width = 523
        Height = 325
        Columns = <
          item
            Caption = 'Name'
            Width = 110
          end
          item
            Caption = 'Type'
            Width = 68
          end
          item
            Caption = 'Offset'
            Width = 43
          end
          item
            Caption = 'Flags'
          end
          item
            Caption = 'Attributes'
            Width = 60
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'Published Methods'
      ImageIndex = 5
      object lstPublishedMethods: TListView
        Left = 3
        Top = 3
        Width = 520
        Height = 325
        Columns = <
          item
            Caption = 'Name'
            Width = 116
          end
          item
            Caption = 'Address'
            Width = 64
          end
          item
            Caption = 'Calling Conv.'
            Width = 80
          end
          item
            Caption = 'Stack size'
            Width = 70
          end
          item
            Caption = 'Param Count'
            Width = 80
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object Al: TTabSheet
      Caption = 'All RTTI Methods'
      ImageIndex = 6
      object lstMethods: TListView
        Left = 0
        Top = 3
        Width = 523
        Height = 325
        Columns = <
          item
            Caption = 'Name'
            Width = 116
          end
          item
            Caption = 'Address'
            Width = 68
          end
          item
            Caption = 'Calling Conv.'
            Width = 80
          end
          item
            Caption = 'Result Type'
            Width = 70
          end
          item
            Caption = 'Param Count'
            Width = 80
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
end
