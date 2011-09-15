unit UTabelFromSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTable, StrUtils, UTableStruct, IniFiles, UEditFromSchedule;

type
  TSchForm = class(TTableForm)
  public
    Sel: TPoint;
    procedure RefreshSql; override;
    procedure SetWhere(const Value: String);
    constructor Create(AOwner: TComponent); override;
    procedure ReadIni(FileName: String); override;
    procedure GridDblClick2(Sender: TObject);
    procedure AddRecordClick1(Sender: TObject);
  private
    FWhere: String;
    property Where: String read FWhere write SetWhere;
  end;

var
  SchForm: TSchForm;

implementation

{$R *.dfm}

{ TForm2 }

procedure TSchForm.AddRecordClick1(Sender: TObject);
var
  New: TEditFormFromSch;
  TmpID: String;

begin
  New := TEditFormFromSch.Create(Application);
  New.SetTableProp(TableProp);
  New.Sel := Sel;
  with New do begin
    SetDataBaseSettings;
    DataSet.Insert;
    TmpID := DataSet.FieldByName(TableProp.FieldsNamesForEdit[0]).AsString;
    SetSelectSQL(TmpID);
    Caption := Caption + 'ID = ' + TmpID;
    OnFormCLose := OnEditFormCLose;
  end;
  if Assigned(OnUpdate) then OnUpdate(Self);
end;

constructor TSchForm.Create;
begin
  inherited;
  AddFilterBtn.Enabled := False;
  AddRecord.Enabled := False;
  TableProp := TScheduleItemsTable.Create;
  Grid.OnDblClick := GridDblClick2;
  AddRecord.OnClick := AddRecordClick1;
end;

procedure TSchForm.GridDblClick2(Sender: TObject);
var
  New: TEditFormFromSch;
  TmpID: String;

begin
  New := TEditFormFromSch.Create(Application);
  New.Sel := Sel;
  New.SetDataBaseSettings;
  TmpID := Query.FieldByName(TableProp.FieldsNamesForEdit[0]).AsString;
  New.SetSelectSQL(TmpID);
  New.Caption := New.Caption + 'ID = ' + TmpID;
  New.OnFormCLose := OnEditFormCLose;
  if Assigned(OnUpdate) then OnUpdate(Self);
end;

procedure TSchForm.ReadIni(FileName: String);
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\IniFiles\' + FileName);
end;

procedure TSchForm.RefreshSql;
var
  SortOrder: String;

begin
  Query.Active := False;
  If OrderNumber <> 0 then begin
    SortOrder := ' ORDER BY ' + TableProp.Eng[SortColumn] + Order[OrderNumber];
    SortStatus.Panels[0].Text :=
      'Сoртировать ' + TableProp.Rus[SortColumn] +
      IfThen(OrderNumber = 1, ' по возрастанию',' по убыванию');
  end
  else begin
    SortOrder := 'ORDER BY ID';
    SortStatus.Panels[0].Text := 'Без сортировки';
  end;
  Query.SQL.Text := TableProp.GetQuery + ' ' +
                    where + ' ' +
                    SortOrder;
  Query.Active := True;
  SetColumnsWidth;
end;

procedure TSchForm.SetWhere(const Value: String);
begin
  FWhere := Value;
end;

end.
