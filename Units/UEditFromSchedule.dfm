object EditFormFromSch: TEditFormFromSch
  Left = 0
  Top = 0
  ClientHeight = 288
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object qv: TIBSQL
    Database = DM.Base
    Transaction = DM.Transaction
    Left = 216
    Top = 128
  end
end
