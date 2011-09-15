unit UEditFromSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StrUtils, StdCtrls, DBCtrls, UData, DB, IBQuery,
  UTableStruct, IBSQL, IBCustomDataSet, IBUpdateSQL, UEdit;

type
  TEditFormFromSch = class(TEditForm)
    qv: TIBSQL;
  public
    Sel: TPoint;
    DefaultX, DefaultY: String;
    procedure SetDataBaseSettings(Open: Boolean = True); override;
    constructor Create(AOwner: TComponent); override;
    procedure PostBtnClickWithUpdate(Sender: TObject);
  end;

var
  EditFormFromSch: TEditFormFromSch;

implementation

{$R *.dfm}

{ TForm2 }

constructor TEditFormFromSch.Create;
begin
  inherited;
  TableProp := TScheduleItemsTable.Create;
  PostBtn.OnClick := PostBtnClickWithUpdate;
end;

procedure TEditFormFromSch.PostBtnClickWithUpdate(Sender: TObject);
begin
  if DataSet.Modified then
   DataSet.Post;
  qv := TIBSQL.Create(EditFormFromSch);
  with qv do begin
    Database := dm.Base;
    SQL.Text := TableProp.GetUpdate
    (Sel.X, DefaultX, DataSet.FieldByName('ID').AsString);
    ExecQuery;
    SQL.Text := TableProp.GetUpdate
    (Sel.Y, DefaultY, DataSet.FieldByName('ID').AsString);
    ExecQuery;
    Free;
  end;
  Close;
end;

procedure TEditFormFromSch.SetDataBaseSettings(Open: Boolean = True);
var
  i: Integer;
begin
  PrepareDataSet(Open);
  with TableProp do begin
    for i := 0 to High(Rus) do begin
      GetLabel(i);
      if (References[i].TablesField = '') then
        GetEidt(i).Enabled := not((i = Sel.X) or (i = Sel.Y) or (i = 0))
      else
        GetLookUpComboBox(i).Enabled :=  not((i = Sel.X) or (i = Sel.Y));
    end;
  end;
end;

end.
