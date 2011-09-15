unit UData;

interface

uses
  DB, IBCustomDataSet, IBDatabase, DBCtrls, Classes;

type
  TDM = class(TDataModule)
    Base: TIBDatabase;
    Transaction: TIBTransaction;
  end;


var
  DM: TDM;

implementation

{$R *.dfm}

end.
