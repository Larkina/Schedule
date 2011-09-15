object EditForm: TEditForm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
  ClientHeight = 288
  ClientWidth = 384
  Color = clBtnFace
  Constraints.MinHeight = 295
  Constraints.MinWidth = 392
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollBox: TScrollBox
    Left = 0
    Top = 18
    Width = 384
    Height = 143
    Align = alClient
    TabOrder = 1
  end
  object Navigator: TDBNavigator
    Left = 0
    Top = 0
    Width = 384
    Height = 18
    DataSource = DS
    VisibleButtons = [nbDelete, nbPost, nbCancel]
    Align = alTop
    TabOrder = 0
    Visible = False
  end
  object BtnPanel: TPanel
    Left = 0
    Top = 161
    Width = 384
    Height = 127
    Align = alBottom
    TabOrder = 2
    object PostBtn: TButton
      Left = 16
      Top = 8
      Width = 177
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1080#1079#1084#1077#1085#1077#1085#1080#1103' '#1080' '#1074#1099#1081#1090#1080
      ModalResult = 11
      TabOrder = 0
      OnClick = PostBtnClick
    end
    object CloseWithoutSaveBtn: TButton
      Left = 16
      Top = 39
      Width = 177
      Height = 25
      Caption = #1053#1077' '#1089#1086#1093#1088#1072#1085#1103#1090#1100
      ModalResult = 11
      TabOrder = 1
      OnClick = CloseWithoutSaveBtnClick
    end
    object DeleteBtn: TButton
      Left = 16
      Top = 70
      Width = 177
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1087#1080#1089#1100' '#1080' '#1074#1099#1081#1090#1080
      ModalResult = 11
      TabOrder = 2
      OnClick = DeleteBtnClick
    end
  end
  object DS: TDataSource
    DataSet = DataSet
    Left = 136
    Top = 72
  end
  object DataSet: TIBDataSet
    Database = DM.Base
    Transaction = DM.Transaction
    SelectSQL.Strings = (
      'select * from BAND')
    Left = 192
    Top = 104
  end
end
