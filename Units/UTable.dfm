object TableForm: TTableForm
  Left = 0
  Top = 0
  Caption = #1058#1072#1073#1083#1080#1094#1072
  ClientHeight = 302
  ClientWidth = 504
  Color = clBtnFace
  Constraints.MinHeight = 315
  Constraints.MinWidth = 510
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolPanel: TPanel
    Left = 0
    Top = 0
    Width = 504
    Height = 138
    Align = alTop
    TabOrder = 1
    object AddFilterBtn: TButton
      Left = 138
      Top = 10
      Width = 113
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1092#1080#1083#1100#1090#1088
      TabOrder = 0
      OnClick = AddFilterBtnClick
    end
    object DisActiveFilter: TButton
      Left = 257
      Top = 10
      Width = 115
      Height = 25
      Caption = #1054#1090#1082#1083#1102#1095#1080#1090#1100' '#1092#1080#1083#1100#1090#1088
      TabOrder = 1
      OnClick = DisActiveFilterClick
    end
    object ApplyFilterBtn: TButton
      Left = 16
      Top = 10
      Width = 116
      Height = 25
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100' '#1092#1080#1083#1100#1090#1088
      TabOrder = 2
      OnClick = ApplyFilterBtnClick
    end
    object AddRecord: TButton
      Left = 378
      Top = 10
      Width = 115
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1079#1072#1087#1080#1089#1100
      TabOrder = 3
      OnClick = AddRecordClick
    end
    object ConditionScrollBox: TScrollBox
      Left = 1
      Top = 56
      Width = 502
      Height = 81
      Align = alBottom
      TabOrder = 4
    end
  end
  object FilterStatus: TStatusBar
    Left = 0
    Top = 264
    Width = 504
    Height = 19
    Panels = <
      item
        Width = 270
      end>
  end
  object Grid: TDBGrid
    Left = 0
    Top = 138
    Width = 504
    Height = 126
    Align = alClient
    DataSource = Source
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = GridDblClick
    OnTitleClick = GridTitleClick
  end
  object SortStatus: TStatusBar
    Left = 0
    Top = 283
    Width = 504
    Height = 19
    Panels = <
      item
        Width = 270
      end>
  end
  object Query: TIBQuery
    Database = DM.Base
    Transaction = DM.Transaction
    Filtered = True
    Left = 184
    Top = 168
  end
  object Source: TDataSource
    DataSet = Query
    Left = 136
    Top = 168
  end
end
