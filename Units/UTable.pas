unit UTable;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UData, ComCtrls, Grids, DBGrids, ExtCtrls, StdCtrls, DB,
  IBCustomDataSet, IBTable, IBQuery, IniFiles, Math, UEdit, UTableStruct,
  UFilters;

type
  TTableForm = class(TForm)
    ApplyFilterBtn: TButton;
    SortStatus: TStatusBar;
    AddRecord: TButton;
    ConditionScrollBox: TScrollBox;
    procedure ApplyFilterBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject); virtual;
    procedure AddRecordClick(Sender: TObject);
  private
    FOnFormFree: TNotifyEvent;
    IsFilterActive: Boolean;
    Filters: array of TPanelForFilters;
    FOnUpdate: TNotifyEvent;
    EditForms: array[ 1 .. 1000 ] of Boolean;
    procedure SetOnFormFree(const Value: TNotifyEvent);
    procedure SetOnUpdate(const Value: TNotifyEvent);
    procedure SetOrderNumber(const Value: Integer);
    procedure SetSortColumn(const Value: Integer);
  protected
    FSortColumn: Integer;
    FOrderNumber: Integer;
    Ini: TIniFile;
    property SortColumn: Integer read FSortColumn write SetSortColumn;
    property OrderNumber: Integer read FOrderNumber write SetOrderNumber;
  published
    ToolPanel: TPanel;
    FilterStatus: TStatusBar;
    Grid: TDBGrid;
    Query: TIBQuery;
    Source: TDataSource;
    AddFilterBtn: TButton;
    DisActiveFilter: TButton;
    procedure GridTitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddFilterBtnClick(Sender: TObject);
    procedure ReadIni(FileName: String); virtual;
    procedure RefreshSQL; virtual;
    procedure DisActiveFilterClick(Sender: TObject);
    procedure FreeFilter(Sender: TObject);
    procedure SaveIni;
    property OnFormFree: TNotifyEvent read FOnFormFree write SetOnFormFree;
    property OnUpdate: TNotifyEvent read FOnUpdate write SetOnUpdate;
    procedure OnEditFormClose(Sender: TObject);
    procedure SetColumnsWidth;
    function GetFilterAsText(Names: array of string): String;
  public
    TableProp: TDBTable;
  end;

const
  Order: array[0 .. 2] of String = ('',' ASC',' DESC');

var
  TableForm: TTableForm;

implementation

uses
  StrUtils;

{$R *.dfm}

procedure TTableForm.AddFilterBtnClick(Sender: TObject);
var
  i: Integer;
begin
  SetLength(Filters, length(Filters) + 1);
  Filters[High(Filters)] := TPanelForFilters.Create(ConditionScrollBox);
  with Filters[High(Filters)] do begin
    SetParent(ConditionScrollBox);
    NumberInArray := High(Filters);
    OnDestroy := FreeFilter;
    for i := 0 to High(TableProp.Rus) do
      Field.Items.Add(TableProp.Rus[i]);
    for i := 0 to High(Ratio) do
      Relation.Items.Add(Ratio[i]);
  end;
end;

procedure TTableForm.AddRecordClick(Sender: TObject);
var
  New: TEditForm;
  TmpID: String;
  
begin
  New := TEditForm.Create(Application);
  New.SetTableProp(TableProp);
  with New do begin
    SetDataBaseSettings(True);
    DataSet.Insert;
    TmpID := DataSet.FieldByName(TableProp.FieldsNamesForEdit[0]).AsString;
    //TmpID := ' (select MAX(id) from ' + TableProp.TableName + ')';
    SetSelectSQL(TmpID);
    Caption := Caption + 'ID = ' + TmpID;
    OnFormCLose := OnEditFormCLose;
  end;
  if Assigned(OnUpdate) then OnUpdate(Self);
end;

procedure TTableForm.ApplyFilterBtnClick(Sender: TObject);
begin
  IsFilterActive := True;
  RefreshSQL;
end;

procedure TTableForm.DisActiveFilterClick(Sender: TObject);
begin
  IsFilterActive := False;
  RefreshSQL;
end;

procedure TTableForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveIni;
  If Assigned(OnFormFree) then OnFormFree(Self);
  Action := caFree;
end;

procedure TTableForm.FormCreate(Sender: TObject);
begin
  IsFilterActive := True;
end;

procedure TTableForm.FreeFilter(Sender: TObject);
begin
  FreeAndNil(Filters[(Sender as TPanelForFilters).NumberInArray]);
end;

function TTableForm.GetFilterAsText(Names: array of string): String;
var
  i: Integer;
  t: string;

begin
  for i := 0 to High(Filters) do
    if Filters[i] <> nil then begin
      t := Filters[i].GetStringForSQL(Names);
      if t <> '' then
        Result := Result + t + IfThen( i <> High(Filters), ' AND ','');
    end;
  If Result <> '' then
    Result := 'WHERE ' + Result;
end;

procedure TTableForm.GridDblClick(Sender: TObject);
var
  New: TEditForm;
  TmpID: String;
  
begin
  if not EditForms[ Query.FieldByName(TableProp.FieldsNamesForEdit[0]).AsInteger] then begin
    EditForms[Query.FieldByName(TableProp.FieldsNamesForEdit[0]).AsInteger] := True;
  end
  else
    Exit;
  New := TEditForm.Create(Application);
  TmpID := Query.FieldByName(TableProp.FieldsNamesForEdit[0]).AsString;
  New.SetTableProp(TableProp);
  with New do begin
    SetDataBaseSettings(False);
    SetSelectSQL(TmpID);
    Caption := Caption + 'ID = ' + TmpID;
    OnFormCLose := OnEditFormCLose;
  end;
  if Assigned(OnUpdate) then OnUpdate(Self);
end;

procedure TTableForm.GridTitleClick(Column: TColumn);
begin
  SortColumn := Column.Index;
  OrderNumber := (OrderNumber + 1) mod 3;
  RefreshSQL;
end;

procedure TTableForm.OnEditFormClose(Sender: TObject);
var
  t, n: String;

begin
  t := (Sender as TEditForm).Caption;
  n := Copy(t, Pos('=', t) + 1, Length(t) - Pos('=', t) + 1);
  EditForms[StrToInt(n)] := False;
  If Assigned(OnUpdate) then OnUpdate(Self);
end;

procedure TTableForm.ReadIni(FileName: String);
var
  i: Integer;
  TmpSectionName: String;

begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\IniFiles\' + FileName);
  with Ini do begin
    With Self do begin
      Width := ReadInteger('ChildForm','Width', Width);
      Height := ReadInteger('ChildForm','Height', Height);
      Left := ReadInteger('ChildForm','Left', Left);
      Top := ReadInteger('ChildForm','Top', Top);
    end;
    if ReadInteger('Filter','Count', 0) <> 0 then
      for i := 0 to ReadInteger('Filter','Count', 0) - 1 do begin
        AddFilterBtn.Click;
        TmpSectionName := 'Filter' + IntToStr(i);
        Filters[i].Field.ItemIndex := ReadInteger(TmpSectionName, 'Field', -1);
        Filters[i].Relation.ItemIndex := ReadInteger(TmpSectionName, 'Relation', -1);
        Filters[i].Edit.Text := ReadString(TmpSectionName, 'Text', '');
      end;
    SortColumn := ReadInteger('Sort','Column', 0);
    OrderNumber := ReadInteger('Sort', 'Order', 0);
  end;
end;

procedure TTableForm.RefreshSQL;
var
  SortOrder: String;

begin
  SaveIni;
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
  FilterStatus.Panels[0].Text := GetFilterAsText(TableProp.Rus);
  Query.SQL.Text := TableProp.GetQuery + ' ' +
                    GetFilterAsText(TableProp.Eng) + ' ' +
                    SortOrder;
  Query.Active := True;
  SetColumnsWidth;
end;

procedure TTableForm.SaveIni;
var
  NotEmpty, i: Integer;

begin
  with Ini do begin
    With Self do begin
      WriteInteger('ChildForm','Width', Width);
      WriteInteger('ChildForm','Height', Height);
      WriteInteger('ChildForm','Left', Left);
      WriteInteger('ChildForm','Top', Top);
    end;
    NotEmpty := 0;
    for i := 0 to High(Filters) do
      if (Filters[i] <> Nil) then begin
        Inc(NotEmpty);
        if Filters[i].Field.ItemIndex <> -1 then
          WriteInteger('Filter' + IntToStr(i),
            'Field', Filters[i].Field.ItemIndex);
        WriteInteger('Filter' + IntToStr(i),
            'Relation', Filters[i].Relation.ItemIndex);
        WriteString('Filter' + IntToStr(i), 'Text', Filters[i].Edit.Text);
      end;
    WriteInteger('Filter', 'Count', NotEmpty);
    WriteInteger('Sort', 'Column', SortColumn);
    WriteInteger('Sort', 'Order', OrderNumber);
    for i := 0 to Grid.Columns.Count - 1 do
      WriteInteger(TableProp.TableName, TableProp.Eng[i], Grid.Columns[i].Width);
  end;
end;

procedure TTableForm.SetColumnsWidth;
var
  i: Integer;
begin
  with Grid do
    for i := 0 to Columns.Count - 1 do begin
      Columns[i].Width := Ini.ReadInteger(TableProp.TableName, TableProp.Eng[i], 100);
      Columns[i].Title.Caption := TableProp.Rus[i];
    end;
end;

procedure TTableForm.SetOnFormFree(const Value: TNotifyEvent);
begin
  FOnFormFree := Value;
end;

procedure TTableForm.SetOnUpdate(const Value: TNotifyEvent);
begin
  FOnUpdate := Value;
end;

procedure TTableForm.SetOrderNumber(const Value: Integer);
begin
  FOrderNumber := Value;
end;

procedure TTableForm.SetSortColumn(const Value: Integer);
begin
  FSortColumn := Value;
end;

end.
