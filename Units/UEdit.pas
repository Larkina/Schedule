unit UEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UData, DB, IBCustomDataSet, ExtCtrls, DBCtrls, StrUtils, StdCtrls,
  Mask, UTableStruct, Grids, DBGrids, IBQuery;

type
  TEditForm = class(TForm)
    DS: TDataSource;
    DataSet: TIBDataSet;
    Navigator: TDBNavigator;
    ScrollBox: TScrollBox;
    BtnPanel: TPanel;
    PostBtn: TButton;
    CloseWithoutSaveBtn: TButton;
    DeleteBtn: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PostBtnClick(Sender: TObject);
    procedure CloseWithoutSaveBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);

  private
    FOnFormCLose: TNotifyEvent;
    FTableProp: TDBTable;
    procedure SetOnFormCLose(const Value: TNotifyEvent);
  protected
    function GetEidt(Index: Integer): TDBEdit;
    function GetLookUpComboBox(Index: Integer): TDBLookupComboBox;
    function GetLabel(Index: Integer): TLabel;
    procedure PrepareDataSet(ShouldOpen: Boolean);
  public
    procedure SetTableProp(const Value: TDBTable);
    property TableProp: TDBTable read FTableProp write SetTableProp;
    property OnFormCLose: TNotifyEvent read FOnFormCLose write SetOnFormCLose;
    procedure SetDataBaseSettings(Open: Boolean = True); virtual;
    procedure SetSelectSQL(ID: String);
  const
    DistY = 10;
    DistX = 30;
  end;

var
  EditForm: TEditForm;

implementation

{$R *.dfm}

{ TEditForm }

procedure TEditForm.CloseWithoutSaveBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TEditForm.DeleteBtnClick(Sender: TObject);
begin
  try
    DataSet.Delete;
  except
    on e: Exception do
      ShowMessage(
      'Все плохо, скорее всего, вы пытались удалить запись, ' +
      'которая участвует в других связаных таблицах, сначала удалите записи в них');
  end;
  Close;
end;

procedure TEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(OnFormCLose) then OnFormCLose(Self);
end;

function TEditForm.GetEidt(Index: Integer): TDBEdit;
begin
  Result := TDBEdit.Create(ScrollBox);
  Result.Parent := ScrollBox;
  Result.DataSource := DS;
  Result.DataField := TableProp.FieldsNamesForEdit[Index];
  Result.Top := Index * DistX + DistY;
  Result.Left := DistY * DistY  + 2 * DistY;
  Result.Enabled := not(Index = 0);
end;

function TEditForm.GetLabel(Index: Integer): TLabel;
begin
  Result := TLabel.Create(ScrollBox);
  Result.Caption := TableProp.Rus[Index];
  Result.Parent := ScrollBox;
  Result.Top := Index * DistX + DistY;
  Result.Left := DistY;
end;

function TEditForm.GetLookUpComboBox(Index: Integer): TDBLookupComboBox;
var
  QueryForLooUp: TIBQuery;
  DataSourceForQuery: TDataSource;
begin
  QueryForLooUp := TIBQuery.Create(ScrollBox);
  DataSourceForQuery := TDataSource.Create(ScrollBox);
  DataSourceForQuery.DataSet := QueryForLooUp;
  QueryForLooUp.Database := DM.Base;
  QueryForLooUp.SQL.Text :=
    'SELECT * FROM ' + TableProp.References[Index].FromTable;
  QueryForLooUp.Open;
  Result := TDBLookupComboBox.Create(ScrollBox);
  Result.Parent := ScrollBox;
  Result.DataSource := DS;
  Result.DataField := TableProp.References[Index].TablesField;
  Result.ListSource := DataSourceForQuery;
  Result.ListField := TableProp.References[Index].LookUpField;
  Result.KeyField := 'ID';
  Result.Top := Index * DistX + DistY;
  Result.Left := DistY * DistY  + 2 * DistY;
  Result.DropDownRows := 10;
end;

procedure TEditForm.PostBtnClick(Sender: TObject);
begin
   If DataSet.Modified then
     DataSet.Post;
   Close;
end;

procedure TEditForm.PrepareDataSet(ShouldOpen: Boolean);
begin
  with DataSet, TableProp do begin
    Close;
    GeneratorField.Field := 'ID';
    GeneratorField.Generator := 'GEN_'+  TableName + '_ID';
    SelectSQL.Text := 'Select * FROM ' + TableName;
    RefreshSQL.Text := SelectSQL.Text;
    DeleteSQL.Text := GetDeleteQuery;
    InsertSQL.Text := GetInsertQuery;
    ModifySQL.Text := GetUpdateQuery;
    If ShouldOpen then begin
      Open;
      FetchAll;
    end;
   end;
end;

procedure TEditForm.SetDataBaseSettings(Open: Boolean = True);
var
  i: Integer;
begin
  PrepareDataSet(Open);
  with TableProp do begin
    for i := 0 to High(Rus) do begin
        GetLabel(i);
      if (References[i].TablesField = '') then
        GetEidt(i)
      else
        GetLookUpComboBox(i);
    end;
  end;
end;

procedure TEditForm.SetOnFormCLose(const Value: TNotifyEvent);
begin
  FOnFormCLose := Value;
end;

procedure TEditForm.SetTableProp(const Value: TDBTable);
begin
  FTableProp := Value;
end;

procedure TEditForm.SetSelectSQL(ID: String);
begin
  DataSet.Close;
  DataSet.SelectSQL.Text := 'SELECT * FROM ' + TableProp.TableName + ' WHERE ID=' + ID;
  DataSet.Open;
end;

end.
