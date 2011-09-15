unit UShowSchedule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, DB, IBCustomDataSet, IBQuery, StdCtrls, UData,
  UTableStruct, DBGrids, Math, StrUtils, Menus, ComObj, Excel2000, ShellAPI,
  Office2000, Buttons, UTabelFromSchedule, UEditFromSchedule, ImgList, Types,
  UConflicts, UFilters;

type
  Strings = array of String;
  BoolArray = array of Boolean;
  IntArray = array of Integer;
  PInteger = ^Integer;

  TScheduleForm = class(TForm)
    DS: TDataSource;
    PopupMenu: TPopupMenu;
    Panel: TPanel;
    FilterPanel: TPanel;
    EditBtn: TBitBtn;
    AddBtn: TBitBtn;
    VerQuery: TIBQuery;
    ScheduleQuery: TIBQuery;
    HorQuery: TIBQuery;
    ShowBtn: TBitBtn;
    DeleteBtn: TBitBtn;
    ExportGrouBox: TGroupBox;
    ExportToExcelBtn: TButton;
    ExportToHtml: TButton;
    HtmlSave: TSaveDialog;
    ExcelSave: TSaveDialog;
    Grid: TDrawGrid;
    ConfBtn: TBitBtn;
    GroupBoxForCtrls: TGroupBox;
    Vertical: TComboBox;
    Horizontal: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ChooseBtn: TButton;
    EmptySpaceCheckBox: TCheckBox;
    SeparateCheckBox: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure ClrFilterBtnClick(Sender: TObject);
    procedure SeparateCheckBoxClick(Sender: TObject);
    procedure ChooseBtnClick(Sender: TObject);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure FormDeactivate(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure EditBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure OnEditFormClose(Sender: TObject);
    procedure GridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure GridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ShowBtnClick(Sender: TObject);
    procedure ExportToExcelBtnClick(Sender: TObject);
    procedure ExportToHtmlClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure ConfBtnClick(Sender: TObject);
  private
    Filter: TPanelForFilters;
    Table: TScheduleItemsTable;
    Hint: THintWindow;
    RowFixed, ColFixed: Strings;
    ColWidth: Integer;
    HintText: String;
    VisibleRows, VisibleCols: BoolArray;
    Values: array of array of array of String;
    Sel, MouseCoord: TPoint;
    NumberInCells: Integer;
    Btns: array [1 .. 5] of TBitBtn;
    Conflicts: TConflictControl;
    procedure PrepareValuesAndGrid;
    function GetWidth(AStr: String): Integer;
    function GetHeight(AStr: String): Integer;
    procedure HideBtns;
    function Dialog: Integer;
  end;

var
  ScheduleForm: TScheduleForm;

implementation

{$R *.dfm}

procedure TScheduleForm.ClrFilterBtnClick(Sender: TObject);
begin
  Filter.Field.ItemIndex := -1;
  Filter.Relation.ItemIndex := -1;
  Filter.Edit.Text := '';
  ChooseBtn.Click;
end;

procedure TScheduleForm.ConfBtnClick(Sender: TObject);
var
  item: TConflictMenuItem;
  confid: TIntegerDynArray;
  i: Integer;
begin
  PopupMenu.Items.Clear;
  confid := Conflicts.IsIdInConflict(Values[Sel.X, Sel.Y, NumberInCells]);
  for i := 0 to High(confid) do begin
    item := TConflictMenuItem.Create(Self);
    item.Caption := Conflicts.Conf[Confid[i]].Name;
    PopupMenu.Items.Add(Item);
  end;
  PopupMenu.Popup(MouseCoord.X, MouseCoord.Y + Panel.Height);
end;

procedure TScheduleForm.DeleteBtnClick(Sender: TObject);
var
  q: TIBQuery;
begin
  if MessageDlg('Вы уверены, что хотите удалить запись?',
    mtConfirmation, mbOKCancel, 0, mbOK) = mrNo then Exit;
  q := TIBQuery.Create(Self);
  with q do begin
    Database := DM.Base;
    SQL.Text := 'DELETE FROM ' + Table.TableName +
      ' WHERE ID =' + Values[Sel.X, Sel.Y, NumberInCells];
    Open;
  end;
  DM.Transaction.Commit;
  PrepareValuesAndGrid;
  HideBtns;
end;

function TScheduleForm.Dialog: Integer;
begin
 Result := MessageDlg('Экспорт завершен, открыть файл?', mtConfirmation, mbYesNo, 0)
end;

procedure TScheduleForm.EditBtnClick(Sender: TObject);
var
  New: TEditFormFromSch;
  TmpID: String;

begin
  TmpID := Values[Sel.X, Sel.Y, NumberInCells];;
  New := TEditFormFromSch.Create(Application);
  with New do begin
    Sel := Self.Sel;
    SetDataBaseSettings;
    SetSelectSQL(TmpID);
    Caption := New.Caption + 'ID = ' + TmpID;
    OnFormCLose := OnEditFormCLose;
  end;
end;

procedure TScheduleForm.ExportToHtmlClick(Sender: TObject);
const HTML_Header=
  '<html>'+
  '<head>' +
  '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>'+
  '<title>Расписание</title>'+
  '</head>'+
  '<style>' +
    'body{background-color: #EEEEFF; font-family: Tahoma; color: #000000}' +
    'table{font-size: 8pt}'+
    'table.schedule td{border: #C0DCC0 0pt solid; background-color: #F0FBFF; vertical-align: top}'+
    'table.schedule th{font-size: 14pt; font-weight: bold; background-color: #C8C8C8 ; text-align: center; vertical-align: middle}'+
    'table.schedule td.full{background-color: #99CCFF}'+
    'table.schedule td.alone{background-color: #FFFFFF}'+
    'table.schedule td.another{background-color: #FFFFCC}'+
  '</style>'+
  '<body>';
var
  s, ss: string;
  i, j, k, z: Integer;
  q: TIBQuery;
begin
  if not HtmlSave.Execute then Exit;
  q := TIBQuery.Create(Self);
  q.Database := DM.Base;
  ReWrite(output, HtmlSave.FileName);
  Writeln(HTML_Header);
  s := Filter.GetStringForSQL(Table.Rus);
  Writeln('<center><h1> Расписание </h1></center>');
  Writeln('<center><h2> По горизонтали: ' + Horizontal.Text +
    '.  По вертикали: '+ Vertical.text +'</h2></center>');
  Writeln('<center><h3> '+ IfThen(s = '', 'Нет фильтрации', 'Фильтр:' + s) +' </h3></center>');
  Writeln('<table class="schedule"; border = "2">'); {; }
  Writeln('<tr>');
  Writeln('<th> <br/> </th>');
  for i := 1 to High(ColFIxed) do
    if Grid.ColWidths[i] <> -1 then
      writeln('<th>' + ColFixed[i] + '</th>');
   writeln('</tr>');
  for j := 1 to Grid.RowCount - 1 do begin
    if Grid.RowHeights[j] = -1 then Continue;
    writeln('<tr>');
    writeln('<th>' + RowFixed[j] + '</th>');
    for i := 1 to Grid.ColCount - 1 do begin
      if Grid.ColWidths[i] = -1 then Continue;
      If Length(Values[i, j]) = 1 then
        ss := 'class="alone"'
      else
        If Length(Values[i, j]) = 0 then
          ss := 'class="another"'
        else
          ss := 'class="full"';
      writeln('<td ' + ss + '>');
      s := '';
      for k := 0 to High(Values[i, j]) do begin
        q.SQL.Text := Table.GetQuery + ' WHERE a.ID =' + Values[i, j, k];
        q.Open;
        for z := 1 to High(Table.Eng) do
          s := s + IfThen(SeparateCheckBox.Checked, Table.Rus[z] + ': ', '') +
            q.Fields[z].AsString + '<br>';
        Q.Close;
        s := s + '<br>';
      end;
      if s = '' then s := '<br>';
      writeln(s  + '</td>');
    end;
    writeln('</tr>');
  end;
  writeln('</table>');
  writeln('</body>');;
  writeln('</html>');
  CloseFile(output);
  if Dialog = mrYes then
    ShellExecute(Handle, 'open', PChar(HtmlSave.Filename), '', nil, SW_NORMAL);
end;

procedure TScheduleForm.AddBtnClick(Sender: TObject);
var
  New: TEditFormFromSch;
  TmpID: String;

begin
  New := TEditFormFromSch.Create(Application);
  with New do begin
    SetTableProp(Table);
    DefaultX := ColFixed[Self.Sel.X];
    DefaultY := RowFixed[Self.Sel.Y];
    Sel.X := Vertical.ItemIndex + 1;
    Sel.Y := Horizontal.ItemIndex + 1;
    SetDataBaseSettings;
    DataSet.Insert;
    TmpID := DataSet.FieldByName(TableProp.FieldsNamesForEdit[0]).AsString;
    SetSelectSQL(TmpID);
    Caption := Caption + 'ID = ' + TmpID;
    OnFormCLose := OnEditFormClose;
  end;
end;

procedure TScheduleForm.ExportToExcelBtnClick(Sender: TObject);
var
  xl: OleVariant;
  i, j, k, z: Integer;
  s: string;
  q: TIBQuery;

  function RefToCell(ARow, ACol: Integer): string;
  var
    s1: string;
    c, c1: integer;
  begin
    if ACol > 26 then begin
      c := ACol div 26;
      c1 := ACol mod 26;
      s1 := Chr(Ord('A') + c - 1) + Chr(Ord('A') + c1 - 1);
    end
    else
      s1 := Chr(Ord('A') + ACol - 1);
    Result := s1 + IntToStr(ARow);
  end;

begin
  if not ExcelSave.Execute then Exit;
  q := TIBQuery.Create(Self);
  q.Database := Dm.Base;
  xl := CreateOleObject('Excel.Application');
  xl.Visible := False;
  xl.Workbooks.Add;
  xl.Workbooks[1].WorkSheets[1].Name := Table.TableName + ' table';
  xl.Columns.ColumnWidth := 50;
  xl.Range[RefToCell(1,1),RefToCell(1,Grid.ColCount)].Select;
  xl.selection.merge;
  xl.Range[RefToCell(2,1),RefToCell(2,Grid.ColCount)].Select;
  xl.selection.merge;
  xl.Range[RefToCell(3,1),RefToCell(3,Grid.ColCount)].Select;
  xl.selection.merge;
  xl.Range[RefToCell(1,1),RefToCell(3 ,Grid.ColCount)].Font.Size := 20;
  xl.Range[RefToCell(1,1),RefToCell(3 ,Grid.ColCount)].Interior.Color := clWebCoral;
  xl.Range[RefToCell(1,1),RefToCell(3 ,Grid.ColCount)].Borders.LineStyle := xlDouble;
  s := Filter.GetStringForSQL(Table.Rus);
  xl.cells[1,1] := 'Расписание';
  xl.cells[2,1] := 'По горизонтали: ' + Horizontal.Text + '  По вертикали: ' + Vertical.Text;
  xl.cells[3,1] := IfThen(s = '', 'Нет фильтрации', 'Фильтр:' + s);
  for i := 1 to High(RowFixed) do
    xl.Cells[i + 4, 1] := RowFixed[i];
  for j := 1 to High(ColFixed) do begin
    xl.Cells[4, j + 1] := ColFixed[j];
  end;
  for i := 1 to High(Values) do
    for j := 1 to High(Values[i]) do
    begin
      s := '';
      If Length(Values[i, j]) = 1 then
        xl.Cells[j + 4,i + 1].Interior.Color := clWhite
      else
        If Length(Values[i, j]) = 0 then
          xl.Cells[j + 4,i + 1].Interior.Color := clCream
        else
          xl.Cells[j + 4,i + 1].Interior.Color := clSkyBlue;
      for k := 0 to High(Values[i, j]) do begin
        q.SQL.Text := Table.GetQuery + ' WHERE a.ID =' + Values[i, j, k];
        q.Open;
        for z := 1 to High(Table.Eng) do
          s := s + IfThen(SeparateCheckBox.Checked,
              Table.Rus[z] + ': ', '') + q.Fields[z].AsString + #10;
        Q.Close;
        s := s + #10;
      end;
      xl.Cells[j + 4, i + 1] := s;
    end;
  for i := 0 to High(RowFixed) do begin
    xl.Rows[i + 4].EntireRow.AutoFit;
    xl.Rows[i + 4].Select;
    xl.Cells[i + 4, 1].Interior.Color := clSilver;
    if Grid.RowHeights[i] = -1 then
      xl.Selection.EntireRow.Hidden := True;
   xl.Selection.VerticalAlignment := xlTop;
   xl.Selection.HorizontalAlignment := xlLeft;
   xl.Selection.Borders.LineStyle := xlDouble;
  end;
  for i := 0 to High(ColFixed) do begin
    xl.Columns[i + 1].EntireColumn.AutoFit;
    xl.Cells[4, i + 1].Interior.Color := clSilver;
    if Grid.ColWidths[i] = -1 then
      xl.Columns[i + 1].EntireColumn.Hidden := True;
    xl.Selection.VerticalAlignment := xlTop;
    xl.Selection.HorizontalAlignment := xlLeft;
    xl.Selection.Borders.LineStyle := xlDouble;
  end;
  xl.Rows[1].Select;
  xl.Workbooks[1].SaveAs(ExcelSave.FileName);
  if Dialog = mrYes then
    xl.Visible := True
  else
    xl.Quit;
  xl := Unassigned;
end;

procedure TScheduleForm.ChooseBtnClick(Sender: TObject);
begin
  Hint.ReleaseHandle;
  PrepareValuesAndGrid;
end;

procedure TScheduleForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TScheduleForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Table := TScheduleItemsTable.Create;
  Conflicts := TConflictControl.Create(DM.Base);
  for i := 1 to High(Table.Rus) do begin
    Horizontal.Items.Add(Table.Rus[i]);
    Vertical.Items.Add(Table.Rus[i]);
  end;
  Horizontal.ItemIndex := 0;
  Vertical.ItemIndex := 1;
  Filter := TPanelForFilters.Create(FilterPanel);
  with Filter do begin
    SetParent(FilterPanel);
    CloseBtn.Free;
    for i := 0 to High(Table.Rus) do
      Field.Items.Add(Table.Rus[i]);
    for i := 0 to High(Ratio) do
      Relation.Items.Add(Ratio[i]);
  end;
  Hint := THintWindow.Create(Grid);
  Hint.Parent := Grid;
  Hint.Color := clInfoBk;
  Btns[1] := EditBtn;
  Btns[2] := AddBtn;
  Btns[3] := ShowBtn;
  Btns[4] := DeleteBtn;
  Btns[5] := ConfBtn;
  ChooseBtn.Click;
end;

procedure TScheduleForm.FormDeactivate(Sender: TObject);
begin
  Hint.ReleaseHandle;
end;

function TScheduleForm.FormHelp(Command: Word; Data: Integer;
  var CallHelp: Boolean): Boolean;
begin
  Hint.ReleaseHandle;
  Result := False;
end;

function TScheduleForm.GetHeight(AStr: String): Integer;
begin
  Result := Grid.Canvas.TextHeight(AStr);
end;

function TScheduleForm.GetWidth(AStr: String): Integer;
begin
  Result := Grid.Canvas.TextWidth(AStr);
end;

procedure TScheduleForm.GridDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  ColEnd, RowEnd,ColStart, RowStart, Num: integer;
  q: TIBQuery;

  procedure Update(Index: Integer; Fixed, Id: String);
  begin
    q.Close;
    q.SQL.Text := Table.GetUpdate(Index, Fixed, Id);
    q.Open;
    DM.Transaction.Commit;
  end;

begin
  Grid.MouseToCell(x, y, ColEnd, RowEnd);
  Grid.MouseToCell(MouseCoord.X, MouseCoord.Y, ColStart, RowStart);
  try
    q := TIBQuery.Create(ScheduleForm);
    q.Database := DM.Base;
    Num := ( MouseCoord.Y - Grid.CellRect(ColStart, RowStart).Top) div (GetHeight('A') * 6);
    If Num > High(Values[ColStart, RowStart]) then
      Num := High(Values[ColStart, RowStart]);
    Update(Vertical.ItemIndex + 1, ColFixed[ColEnd], Values[ColStart, RowStart, Num]);
    Update(Horizontal.ItemIndex + 1, RowFixed[RowEnd], Values[ColStart, RowStart, Num]);
  finally
    q.Free;
  end;
  HideBtns;
  ChooseBtn.Click;
end;

procedure TScheduleForm.GridDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  col, row: integer;
begin
  grid.MouseToCell(X, Y, col, row);
  Accept := (col <> 0) and (row <> 0);
end;

procedure TScheduleForm.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Y, i, k: Integer;
  q: TIBQuery;
  t: TRect;

begin
  Y := Rect.Top + 5;
  q := TIBQuery.Create(Grid);
  q.Database := DM.Base;
  Grid.Canvas.Brush.Color := clWhite;
  if (ACol = 0) and (ARow = 0) then
    Exit;
  if (ACol = 0) then
    Grid.Canvas.TextOut(Rect.Left + 10, Rect.Top + 5, RowFixed[ARow])
  else
    if (ARow = 0) then
      Grid.Canvas.TextOut(Rect.Left + 10, Rect.Top + 5, ColFixed[ACol])
    else
      if (Length(Values[ACol, ARow]) <> 0) then begin
        if Length(Values[ACol, ARow]) > 1 then begin
          Grid.Canvas.Brush.Color := clSkyBlue;
          Grid.Canvas.Rectangle(Rect);
        end;
        for k := 0 to High(Values[ACol, ARow]) do begin
          if (Length(Conflicts.IsIdInConflict(Values[ACol, ARow, k])) <> 0) then begin
            with t do begin
              Left := Rect.Left;
              Top := Y - 5;
              Right := Rect.Right;
              Bottom := GetHeight('A') * 7 + Y;
            end;
            Grid.Canvas.Brush.Color := $8080FF;
            Grid.Canvas.Rectangle(t);
          end;
          q.SQL.Text := Table.GetQuery + ' WHERE a.ID =' + Values[ACol, ARow, k];
          q.Open;
          for i := 1 to High(Table.Eng) do begin
            Grid.Canvas.TextOut(Rect.Left + 5, Y, IfThen(SeparateCheckBox.Checked,
              Table.Rus[i] + ': ', '') + q.Fields[i].AsString);
            Inc(Y, GetHeight(q.Fields[i].AsString));
            ColWidth := Max(ColWidth, GetWidth(IfThen(SeparateCheckBox.Checked,
              Table.Rus[i] + ': ', '') + q.Fields[i].AsString));
          end;
          Inc(Y, GetHeight(q.Fields[High(Table.Eng)].AsString));
          q.Close;
        end;
        Grid.ColWidths[ACol] := ColWidth + 25;
      end
    else begin
      Grid.Canvas.Brush.Color := clCream;
      Grid.Canvas.Rectangle(Rect);
    end;
  q.Free;
end;

procedure TScheduleForm.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow, TextHeight, TextWidth, i, j: Integer;
  q: TIBQuery;
  Rect: TRect;

begin
  Grid.MouseToCell(X, Y, ACol, ARow);
  MouseCoord := Point(X,Y);
  Rect := Grid.CellRect(ACol, ARow);
  NumberInCells := (MouseCoord.Y - Rect.Top) div (GetHeight('A') * 6);
  If NumberInCells > High(Values[ACol, ARow]) then
    NumberInCells := High(Values[ACol, ARow]);
  for i := 1 to High(Btns) do begin
    Btns[i].Visible := (Length(Values[ACol, ARow]) > 0);
    If i = 5 then
      Btns[i].Visible := Length(Conflicts.IsIdInConflict(Values[Sel.X, Sel.Y, NumberInCells])) <> 0;
    Btns[i].Left := Rect.Right - (i div 5 + 1) * Btns[i].Width;
    Btns[i].Top := Rect.Top + ((i - 1) mod 4) * Btns[i].Height +
      Max(NumberInCells * GetHeight('A') * 7, 0) + 5 + Panel.Height;
    Btns[i].BringToFront;
  end;
  AddBtn.Visible := True;
  HintText := '';
  TextWidth := 0;
  q := TIBQuery.Create(Grid);
  try
    q.Database := DM.Base;
    for j := 0 to High(Values[ACol, ARow]) do begin
      q.SQL.Text := Table.GetQuery + ' WHERE a.ID =' + Values[ACol, ARow, j];
      q.Open;
      for i := 1 to High(Table.Eng) do
      begin
        HintText := HintText + IfThen(SeparateCheckBox.Checked,
          Table.Rus[i] + ': ', '') + q.Fields[i].AsString + sLineBreak;
        TextWidth := Max(TextWidth, GetWidth(IfThen(SeparateCheckBox.Checked,
              Table.Rus[i] + ': ', '') + q.Fields[i].AsString));
      end;
    end;
  finally
    q.Free;
  end;
  If HintText = '' then begin
    Hint.ReleaseHandle;
    Exit;
  end;
  with Rect do begin
    Left := X;
    Top := Y + Panel.Height + 100;
    TextHeight := GetHeight(HintText) * (Length(Values[ACol, ARow]));
    Right := TextWidth + Left + 5;
    Bottom := Top + TextHeight * 6 + 5;
  end;
  Hint.ActivateHint(Rect, HintText);
  grid.BeginDrag(false, 5);
end;

procedure TScheduleForm.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  Sel.X := ACol;
  Sel.Y := ARow;
end;

procedure TScheduleForm.HideBtns;
var i: Integer;
begin
  for i := 1 to High(Btns) do
    Btns[i].Visible := False;
end;

procedure TScheduleForm.OnEditFormClose(Sender: TObject);
begin
  ChooseBtn.Click;
end;

procedure TScheduleForm.PrepareValuesAndGrid;
var
  s, s1: string;
  k, i, j: Integer;

  function GetSQl(Index: Integer): String;
  var
    t: TDBTable;
  begin
    t := TypesOfTables[Index].Create;
    Result := t.GetQueryForTitle;
    t.Free;
  end;

  function GetTitles(AQuery: TIBQuery; Index: Integer; ForLength: PInteger): Strings;
  begin
    with AQuery do begin
      Close;
      Sql.Text := GetSql(Index);
      Open;
      First;
      SetLength(Result, 1);
      while not Eof do
      begin
        SetLength(Result, Length(Result) + 1);
        Result[ High(Result)] := Fields[0].Text;
        ColWidth := Min(Max(ColWidth, GetWidth(Fields[0].Text) + 12), 200);
        Next;
      end;
    end;
    ForLength^ := Length(Result);
  end;

  function GetVisible(Col, Row: Strings; Inv: Boolean = False): BoolArray;
  var
    i, j, Empty: Integer;
  begin
    SetLength(Result, Length(Col));
    for i := 1 to High(Col) do
    begin
      Empty := 0;
      for j := 1 to High(Row) do
        if Inv then
          Inc(Empty, Ord(Length(Values[j, i]) = 0))
        else
          Inc(Empty, Ord(Length(Values[i, j]) = 0));
      Result[i] := not(Empty = High(Row));
    end;
  end;

begin
  ScheduleQuery.Close;
  s1 := Filter.GetStringForSQL(Table.Eng);
  ScheduleQuery.SQL.Text := Table.GetQuery + IfThen(s1 = '', '', ' WHERE ' + s1)
    + ' ORDER BY ' + Table.Eng[Vertical.ItemIndex + 1] + ', ' + Table.Eng
    [Horizontal.ItemIndex + 1];
  ScheduleQuery.Open;
  ColWidth := 150;
  RowFixed := GetTitles(HorQuery, Horizontal.ItemIndex, @Grid.RowCount);
  ColFixed := GetTitles(VerQuery, Vertical.ItemIndex, @Grid.ColCount);
  Grid.ColWidths[0] := ColWidth;
  SetLength(Values, 0, 0);
  SetLength(Values, Length(ColFixed), Length(RowFixed));
  ScheduleQuery.First;
  i := 1;
  j := 1;
  while not ScheduleQuery.Eof do
  begin
    s := ScheduleQuery.Fields[Vertical.ItemIndex + 1].AsString;
    s1 := ScheduleQuery.Fields[Horizontal.ItemIndex + 1].AsString;
    while not((ColFixed[i] = s) and (RowFixed[j] = s1)) do
      if j + 1 <= High(Values[i]) then
        Inc(j)
      else begin
        Inc(i);
        j := 1;
      end;
    SetLength(Values[i, j], Length(Values[i, j]) + 1);
    Values[i, j, High(Values[i, j])] := ScheduleQuery.Fields[0].AsString;
    ScheduleQuery.Next;
  end;

  for k := 1 to High(RowFixed) do
    Grid.RowHeights[k] := 100;
  for k := 1 to High(ColFixed) do
    Grid.ColWidths[k] := 30;

  // Пустые строчки столбцы
  SetLength(VisibleRows, 0);
  SetLength(VisibleCols, 0);

  If not EmptySpaceCheckBox.Checked then
  begin

    VisibleCols := GetVisible(ColFixed, RowFixed);
    for k := 1 to High(ColFixed) do
      if not VisibleCols[k] then
        Grid.ColWidths[k] := -1;

    VisibleRows := GetVisible(RowFixed, ColFixed, True);
    for k := 1 to High(RowFixed) do
      if not VisibleRows[k] then
        Grid.RowHeights[k] := -1;
  end;

  Grid.Invalidate;
end;

procedure TScheduleForm.SeparateCheckBoxClick(Sender: TObject);
begin
  PrepareValuesAndGrid;
  Hint.ReleaseHandle;
end;

procedure TScheduleForm.ShowBtnClick(Sender: TObject);
var
  New: TSchForm;
begin
  New := TSchForm.Create(Application);
  New.SetWhere('WHERE ' + Table.Eng[Vertical.ItemIndex + 1] +
    '=' + QuotedStr(ColFixed[Sel.X]) + ' AND ' +
    Table.Eng[Horizontal.ItemIndex + 1] +
    '=' + QuotedStr(RowFixed[Sel.Y]));
  With New do begin
    ReadIni(Table.RusTableName + '.ini');
    Sel.X := Vertical.ItemIndex + 1;
    Sel.Y := Horizontal.ItemIndex + 1;
    RefreshSQL;
  end;
end;

end.
