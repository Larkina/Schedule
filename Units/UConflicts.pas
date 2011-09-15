unit UConflicts;

interface

uses IBQuery, IBDatabase, Menus;

type

  TIntegerDynArray = array of Integer;

  TConflict = class
  public
    Name, q: String;
    Res: array of String;
    constructor Create(db:TIBDatabase; AName, AQuery: String);
    function IsIdInRes(AId: String): Boolean;
  end;

  TConflictControl = class(TObject)
  public
    Conf: array [1 .. 5] of TConflict;
    constructor Create(db:TIBDatabase);
    function IsIdInConflict(AId: String): TIntegerDynArray;
  end;

  TConflictMenuItem = class(TMenuItem)
  public
    ConflictId: Integer;
  end;

implementation

{ TConflict }

constructor TConflict.Create(db:TIBDatabase; AName, AQuery: String);
var
  qv: TIBQuery;
begin
  q := AQuery;
  Name := AName;
  qv := TIBQuery.Create(Nil);
  with qv do begin
    Database := db;
    SQL.Text := q;
    Open;
    First;
    while not Eof do begin
      SetLength(Res, Length(Res) + 1);
      Res[High(Res)] := Fields[0].AsString;
      Next;
    end;
  end;
  qv.Free;
end;

function TConflict.IsIdInRes(AId: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to High(Res) do
    if Res[i] = AId then begin
      Result := True;
      Exit;
    end;
end;

{ TConflictControl }

constructor TConflictControl.Create(db:TIBDatabase);
begin
  Conf[1] := TConflict.Create(db, 'У группы не ведется предмет',
    'select s.ID from SCHEDULEITEMS s where not exists ' +
    '(select * from SUBJECTBAND sb where sb.BANDID = s.BANDID ' +
    ' and sb.SUBJECTID = s.SUBJECTID)');
  Conf[2] := TConflict.Create(db, 'Преподаватель не ведет предмет',
    ' select s.ID from SCHEDULEITEMS s where not exists ' +
    ' (select * from SUBJECTPROFESSOR sp where sp.SUBJECTID = s.SUBJECTID ' +
    '  and sp.PROFESSORID = s.PROFESSORID)');
  Conf[3] := TConflict.Create(db, 'Группа в нескольких местах одновременно',
    ' select sh.id from SCHEDULEITEMS sh where ' +
    ' (select count(s.PERIODID) from SCHEDULEITEMS s ' +
    ' where s.DAYID = sh.DAYID and s.PERIODID = sh.PERIODID and s.BANDID = sh.BANDID ' +
    ' group by s.BANDID rows 1)  > 1 ');
  Conf[4] := TConflict.Create(db, 'Преподаватель находится в нескольких местах одновременно',
    ' select distinct sh.id from SCHEDULEITEMS sh where ' +
    ' (select count(s.PERIODID) from SCHEDULEITEMS s where s.DAYID = sh.DAYID ' +
    ' and s.PERIODID = sh.PERIODID and s.PROFESSORID = sh.PROFESSORID ' +
    ' group by s.PROFESSORID rows 1)  > 1 ');
  Conf[5] := TConflict.Create(db, 'Группа не вмещается в аудиторию',
    ' select sh.id from( select sum(b.AMOUNT) as SumSize, ' +
    ' s.DAYID as d, s.ROOMID as r, s.PERIODID as p from SCHEDULEITEMS s ' +
    ' inner join BAND b on b.ID = s.BANDID group by s.ROOMID, s.PERIODID, s.DAYID) sel ' +
    ' inner join ROOMS on ROOMS.ID = r inner join SCHEDULEITEMS sh on sh.PERIODID = p ' +
    ' and sh.ROOMID = r and sh.DAYID = d where SumSize > Amount ');
end;

function TConflictControl.IsIdInConflict(AId: String): TIntegerDynArray;
var
  i: Integer;
begin
  for i := 1 to High(Conf) do
    if Conf[i].IsIdInRes(AId) then begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := i;
    end;
end;

end.
