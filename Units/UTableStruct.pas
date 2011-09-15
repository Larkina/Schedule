unit UTableStruct;

interface

uses
  SysUtils, DB, IBCustomDataSet, IBQuery, StrUtils;

const
  StandartQuery = 'SELECT * FROM ';

type

  TRefFields = class
  public
    FromTable, TablesField, LookUpField: String;
    procedure Add(AFrom, AField, ALookUp: string);
  end;

  TDBTable = class
  private
    procedure AddField(EngField, RusField: String); overload;
    procedure AddField(EngField, RusField, EidtField: String; RefField: TRefFields); overload;
  public
    Rus, Eng, FieldsNamesForEdit: array of string;
    References: array of TRefFields;
    TableName, Query, RusTableName: String;
    constructor Create; virtual; abstract;
    function GetQuery: String;
    function GetQueryForTitle: String;
    function GetDeleteQuery: String;
    function GetInsertQuery: String;
    function GetUpdateQuery: String;
    function GetUpdate(Index: Integer; AStr, AID: String): String;
  end;

  TBandTable = class(TDBTable)
    constructor Create; override;
  end;

  TDaysTable = class(TDBTable)
    constructor Create; override;
  end;

  TProfessorsTable = class(TDBTable)
    constructor Create; override;
  end;

  TRoomsTable = class(TDBTable)
    constructor Create; override;
  end;

  TSubjectTable = class(TDBTable)
    constructor Create; override;
  end;

  TTimePeriodTable = class(TDBTable)
    constructor Create; override;
  end;

  TSubjectBandTable = class(TDBTable)
    constructor Create; override;
  end;

  TSubjectProfessorTable = class(TDBTable)
    constructor Create; override;
  end;

  TScheduleItemsTable = class(TDBTable)
    constructor Create; override;
  end;

  TTableClass = class of TDbTable;

const
  TypesOfTables: array[0 .. 8] of TTableClass =
    (TSubjectTable, TBandTable, TProfessorsTable,
     TRoomsTable,  TDaysTable,  TTimePeriodTable,
     TScheduleItemsTable, TSubjectBandTable, TSubjectProfessorTable);


implementation

{ TDBTable }

{ TBandTable }

constructor TBandTable.Create;
begin
  AddField('ID', 'Номер');
  AddField('NAME', 'Номер группы');
  AddField('AMOUNT', 'Количество');
  TableName := 'BAND';
  RusTableName := 'Группы';
  Query := StandartQuery + TableName;
end;

{ TDaysTable }

constructor TDaysTable.Create;
begin
  AddField('ID', 'Номер');
  AddField('NAME', 'День недели');
  AddField('SORTORDER', 'Порядок сортировки');
  TableName := 'DAYS';
  RusTableName := 'Дни';
end;

{ TProfessorsTable }

constructor TProfessorsTable.Create;
begin
  AddField('ID', 'Номер');
  AddField('SECONDNAME', 'Фамилия');
  AddField('FIRSTNAME', 'Имя Отчество');
  TableName := 'PROFESSORS';
  RusTableName := 'Преподаватели';
end;

{ TRoomsTable }

constructor TRoomsTable.Create;
begin
  AddField('ID', 'Номер');
  AddField('NAME', 'Номер аудитории');
  AddField('AMOUNT', 'Вместимость');
  TableName := 'ROOMS';
  RusTableName := 'Аудитории';
end;

{ TSubjectTable }

constructor TSubjectTable.Create;
begin
  AddField('ID', 'Номер');
  AddField('NAME', 'Название предмета');
  TableName := 'SUBJECT';
  RusTableName := 'Предметы';
end;

{ TTimePeriodTable }

constructor TTimePeriodTable.Create;
begin
  AddField('ID', 'Номер');
  AddField('NAME', 'Промежуток времени');
  AddField('SORTORDER', 'Порядок сортировки');
  TableName := 'TIMEPERIOD';
  RusTableName := 'Отрезки времени';
end;

{ TSubjectBandTable }

constructor TSubjectBandTable.Create;
var
  Tmp: TRefFields;
  
begin
  Tmp := TRefFields.Create;
  Tmp.Add('', '', '');
  AddField('a.ID', 'Номер', 'ID', tmp);
  Tmp.Add('SUBJECT', 'SUBJECTID', 'NAME');
  AddField('s.NAME', 'Предмет', 'SUBJECTID', Tmp);
  Tmp.Add('BAND', 'BANDID', 'NAME');
  AddField('b.NAME', 'Группа', 'BANDID', tmp);
  TableName := 'SUBJECTBAND';
  RusTableName := 'Предметы у групп';
  Tmp.Free;
end;

{ TSubjectProfessorTable }

constructor TSubjectProfessorTable.Create;
var
  Tmp: TRefFields;
  
begin
  Tmp := TRefFields.Create;
  Tmp.Add('', '', '');
  AddField('a.ID', 'Номер', 'ID', Tmp);
  Tmp.Add('SUBJECT', 'SUBJECTID', 'NAME');
  AddField('s.NAME', 'Предмет', 'SUBJECTID', Tmp);
  Tmp.Add('PROFESSORS', 'PROFESSORID', 'SECONDNAME');
  AddField('p.SECONDNAME', 'Преподаватель', 'PROFESSORID', Tmp);
  TableName := 'SUBJECTPROFESSOR';
  RusTableName := 'Преподаватели предметов';
  Tmp.Free;
end;

{ TScheduleItemsTable }

constructor TScheduleItemsTable.Create;
var
  Tmp: TRefFields;
  
begin
  Tmp := TRefFields.Create;
  Tmp.Add('', '', '');
  AddField('a.ID', 'Номер', 'ID', Tmp);
  Tmp.Add('SUBJECT', 'SUBJECTID', 'NAME');
  AddField('s.NAME', 'Предмет', 'SUBJECTID', Tmp);
  Tmp.Add('BAND', 'BANDID', 'NAME');
  AddField('b.NAME', 'Группа', 'BANDID', Tmp);
  Tmp.Add('PROFESSORS', 'PROFESSORID', 'SECONDNAME');
  AddField('p.SECONDNAME', 'Преподаватель', 'PROFESSORID', Tmp);
  Tmp.Add('ROOMS', 'ROOMID', 'NAME');
  AddField('r.NAME', 'Аудитория', 'ROOMID', Tmp);
  Tmp.Add('DAYS', 'DAYID', 'NAME');
  AddField('d.NAME', 'Дата', 'DAYID', Tmp);
  Tmp.Add('TIMEPERIOD', 'PERIODID', 'NAME');
  AddField('t.NAME', 'Время', 'PERIODID', Tmp);
  TableName := 'SCHEDULEITEMS';
  RusTableName := 'Элементы расписания';
  Tmp.Free;
end;

{ TDBTable }

procedure TDBTable.AddField(EngField, RusField: String);
begin
  SetLength(Eng, Length(Eng) + 1);
  SetLength(Rus, Length(Rus) + 1);
  SetLength(FieldsNamesForEdit, Length(FieldsNamesForEdit) + 1);
  Rus[High(Rus)] := RusField;
  Eng[High(Eng)] := EngField;
  FieldsNamesForEdit[High(FieldsNamesForEdit)] := EngField;
  SetLength(References, Length(References) + 1);
  References[High(References)] := TRefFields.Create;
  with References[High(References)] do begin
    TablesField := '';
    FromTable := '';
    LookUpField := '';
  end;
end;

procedure TDBTable.AddField(EngField, RusField, EidtField: String; RefField: TRefFields);
begin
  SetLength(Eng, Length(Eng) + 1);
  SetLength(Rus, Length(Rus) + 1);
  SetLength(FieldsNamesForEdit, Length(FieldsNamesForEdit) + 1);
  SetLength(References, Length(References) + 1);
  Rus[High(Rus)] := RusField;
  Eng[High(Eng)] := EngField;
  References[High(References)] := TRefFields.Create;
  with References[High(References)] do begin
    FromTable := RefField.FromTable;
    TablesField := RefField.TablesField;
    LookUpField := RefField.LookUpField;
  end;
  FieldsNamesForEdit[High(FieldsNamesForEdit)] := EidtField;
end;

function TDBTable.GetDeleteQuery: String;
begin
 Result := 'DELETE FROM ' + TableName + ' WHERE ID = :ID'
end;

function TDBTable.GetInsertQuery: String;
var
  i: Integer;
begin
  Result := 'INSERT INTO ' + TableName + '(';
  for i := 0 to High(FieldsNamesForEdit) do
    Result := Result + FieldsNamesForEdit[i] +
      IfThen(i <> High(FieldsNamesForEdit),',',')');
  Result := Result + 'VALUES (';
  for i := 0 to High(FieldsNamesForEdit) do
    Result := Result + ':'+ FieldsNamesForEdit[i] +
      IfThen(i <> High(FieldsNamesForEdit),',',')');
end;

function TDBTable.GetQuery: String;
var
  i: Integer;
begin
  if Length(References) = 0 then
    Result := StandartQuery + TableName
  else begin
    Result := 'SELECT ';
    for i := 0 to High(Eng) do
      Result := Result + Eng[i] +
                IfThen(i <> High(Eng), ', ', ' From ' + TableName + ' a ');
    for i := 0 to High(References) do
      If References[i].FromTable <> '' then
        Result := Result + ' inner join ' + References[i].FromTable + ' ' +
                   References[i].FromTable[1] + ' on ' +
                   'a.' + References[i].TablesField  +
                   ' = ' + References[i].FromTable[1] + '.ID';

  end;
end;

function TDBTable.GetQueryForTitle: String;
begin
  If Length(Eng) >= 1 then
    Result := 'SELECT ' + Eng[1] + ' FROM ' + TableName + ' ORDER BY ' + Eng[1]
  else
    Result := '';
end;

function TDBTable.GetUpdate(Index: Integer; AStr, AID: String): String;
begin
  with References[Index] do begin
    Result :=
    'UPDATE SCHEDULEITEMS a set a.' + FieldsNamesForEdit[Index] +
    ' = (SELECT ' + FromTable[1] + '.ID' +
    ' from ' + FromTable + ' ' + FromTable[1] +
    ' WHERE ' +  LookUpField + '=' +  QuotedStr(AStr) + ')' +
    ' WHERE a.id = ' +  AID;
  end;
end;

function TDBTable.GetUpdateQuery: String;
var
  i: Integer;
begin
  Result := 'UPDATE ' + TableName + ' SET ';
  for i := 0 to High(FieldsNamesForEdit) do
    Result := Result + FieldsNamesForEdit[i] + '=:'+ FieldsNamesForEdit[i] +
      IfThen(i <> High(FieldsNamesForEdit),',',' WHERE ID=:OLD_ID');
end;

{ TRefFields }

procedure TRefFields.Add(AFrom, AField, ALookUp: string);
begin
  FromTable := AFrom;
  TablesField := AField;
  LookUpField := ALookUp;
end;

end.
