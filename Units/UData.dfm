object DM: TDM
  OldCreateOrder = False
  Height = 100
  Width = 206
  object Base: TIBDatabase
    Connected = True
    DatabaseName = 
      'localhost:C:\Documents and Settings\Admin\'#1056#1072#1073#1086#1095#1080#1081' '#1089#1090#1086#1083'\Source\Sc' +
      'hedule_15.09.11\TASK3.GDB'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    LoginPrompt = False
    DefaultTransaction = Transaction
    Left = 40
    Top = 24
  end
  object Transaction: TIBTransaction
    DefaultDatabase = Base
    Left = 120
    Top = 24
  end
end
