unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, ActnList, ToolWin, ComCtrls, ExtCtrls,
  StdActns, StdCtrls, UTable, IniFiles, UTableStruct, DBCtrls, IBQuery,
  DB, IBCustomDataSet, UEdit, UShowSchedule, UConflictForm, UTreeViewForm;

{
�������� �����. �������� � ���� ���������� ������, � ������������� �������
� ���������, ����������� � ����������� ^___^
}

type
  TParentForm = class(TForm)
    Menu: TMainMenu;
    mFile: TMenuItem;
    mClose: TMenuItem;
    mControlWindow: TMenuItem;
    mListOfTables: TMenuItem;
    ActionList: TActionList;
    ControlBar: TControlBar;
    WindowClose: TWindowClose;
    WindowCascade: TWindowCascade;
    WindowTileHorizontal: TWindowTileHorizontal;
    WindowTileVertical: TWindowTileVertical;
    WindowMinimizeAll: TWindowMinimizeAll;
    WindowArrange: TWindowArrange;
    ImageList: TImageList;
    WindowsList: TComboBox;
    mCloseWindow: TMenuItem;
    mCascadeWindos: TMenuItem;
    mMinimizeAllWindow: TMenuItem;
    mHorizontally: TMenuItem;
    mVertically: TMenuItem;
    LabelChooseActiveWindow: TLabel;
    ToolBar: TToolBar;
    mShwoScheduleItems: TMenuItem;
    mConflicts: TMenuItem;
    OpenDialog: TOpenDialog;
    mConnectToDB: TMenuItem;
    procedure AddWindow(Sender: TObject);
    procedure WindowsListChange(Sender: TObject);
    procedure WindowsListDropDown(Sender: TObject);
    procedure mCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormFree(Sender: TObject);
    procedure ChildFormUpdate(Sender: TObject);
    procedure mShwoScheduleItemsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mConflictsClick(Sender: TObject);
    procedure mConnectToDBClick(Sender: TObject);
  end;

var
  ParentForm: TParentForm;
  TableCount: array [0 .. 9] of Integer;

implementation

uses UData;

{$R *.dfm}

// �������� ���� � ���������

procedure TParentForm.AddWindow(Sender: TObject);
var
  NewViewTable: TTableForm;
  Index: Integer;

begin
  NewViewTable := TTableForm.Create(Application);
  Index := Menu.Items.Items[2].IndexOf(Sender as TMenuItem);
  Inc(TableCount[Index]);
  WindowsList.Items.Add(NewViewTable.Caption);
  with NewViewTable do begin
    Caption := (Sender as TMenuItem).Caption + ' �' + IntToStr(TableCount[Index]);
    OnFormFree := FormFree;
    OnUpdate := ChildFormUpdate;
    TableProp := TypesOfTables[Index].Create;
    ReadIni((Sender as TMenuItem).Caption + '.ini');
    RefreshSQL;
  end;
end;

// ��������� ������������� property OnUpdate � ��������.

procedure TParentForm.ChildFormUpdate(Sender: TObject);
var
  i: Integer;
  
begin
  for i := 0 to MdiChildCount - 1 do begin
    if (MDIChildren[i] is TTableForm) then
      (MDIChildren[i] as TTableForm).RefreshSQL;
    If (MDIChildren[i] is TEditForm) then begin
      (MDIChildren[i] as TEditForm).DataSet.Close;
      (MDIChildren[i] as TEditForm).DataSet.Open;
    end;
  end;
end;

// ����������� � ���� ������

procedure TParentForm.mConnectToDBClick(Sender: TObject);
begin
  if not OpenDialog.Execute then exit;
  DM.Base.DatabaseName := {'localhost:' + }OpenDialog.FileName;
  DM.Base.Connected := True;
end;

// ��������� �����.
// ��� �������� Parent ����� MDI ���� �� �������������,
// ������� ����������� � ����������� ������

procedure TParentForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
    MDIChildren[i].Free;
end;

// ������� �����
// ��� �������� ��������� ���� ������ � ���������� ������

procedure TParentForm.FormCreate(Sender: TObject);
var
  i: Integer;
  CurrMenuItem: TMenuItem;

begin
  for i := 0 to High(TypesOfTables) do begin
    CurrMenuItem := TMenuItem.Create(Menu);
    CurrMenuItem.Caption := (TypesOfTables[i].Create).RusTableName;
    CurrMenuItem.OnClick := AddWindow;
    Menu.Items.Items[2].Add(CurrMenuItem);
  end;
end;

// ��� �������� ���� � ��������� �������� �������,
// � ��������������� �������� � �������

procedure TParentForm.FormFree(Sender: TObject);
var
  i, Index: Integer;
  CurrTableName: String;

begin
  CurrTableName := (Sender as TTableForm).Caption;
  Index := Pos('�', CurrTableName);
  Delete(CurrTableName, Index - 1, Length(CurrTableName) - Index + 2);
  for i := 0 to Menu.Items.Items[2].Count - 1 do
    If Menu.Items.Items[2].Items[i].Caption = CurrTableName then break;
  Dec(TableCount[i]);
end;

// ��������� �����

procedure TParentForm.mCloseClick(Sender: TObject);
begin
  Close;
end;

// TreeView � �����������

procedure TParentForm.mConflictsClick(Sender: TObject);
begin
  TViewConflictForm.Create(Application);
end;

// �������� ���� � �����������

procedure TParentForm.mShwoScheduleItemsClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to MdiChildCount - 1 do
    if MDIChildren[i] is TScheduleForm then Exit;
  TScheduleForm.Create(Application);
end;

// ��� ����� �� ������� ������ - ������ ���� ��������

procedure TParentForm.WindowsListChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to MDICHildCount - 1 do
    If WindowsList.Items[WindowsList.ItemIndex] = MDIChildren[i].Caption then  begin
      MDIChildren[i].BringToFront;
      Break;
    end;
end;

// ������ ����

procedure TParentForm.WindowsListDropDown(Sender: TObject);
var
  i: Integer;
  StringListForMenu: TStringList;
begin
  WindowsList.Items.Clear;
  StringListForMenu := TStringList.Create;
  for i := 0 to MDICHildCount - 1 do
    StringListForMenu.Add(MDIChildren[i].Caption);
  StringListForMenu.Sort;
  WindowsList.Items.AddStrings(StringListForMenu);
  StringListForMenu.Free;
end;

end.

