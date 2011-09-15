unit UFilters;

interface

Uses
  SysUtils, Classes, StdCtrls, Controls, ExtCtrls;

type

  TPanelForFilters = class(TPanel)
  private
    FOnDestroy: TNotifyEvent;
    const
      Margin = 10;
    procedure CloseBtnClick(Sender: TObject);
    procedure SetOnDestroy(const Value: TNotifyEvent);
    function PrepareRelation(Index: Integer; Arg: String): String;
  public
    NumberInArray: Integer;
    Field, Relation: TComboBox;
    Edit: TEdit;
    CloseBtn: TButton;
    constructor Create(AOwner: TComponent); override;
    procedure SetParent(AParent: TWinControl);
    property OnDestroy: TNotifyEvent read FOnDestroy write SetOnDestroy;
    function GetStringForSQL(Names: array of string): String;
  end;

const
  Ratio: array [0..7] of string =
    ('=','<','>','<=','>=','<>', 'начинается с', 'содержит');

implementation


{ MyPanel }


procedure TPanelForFilters.CloseBtnClick(Sender: TObject);
begin
  Field.Free;
  Relation.Free;
  Edit.Free;
  if Assigned(OnDestroy) then OnDestroy(Self);
end;

constructor TPanelForFilters.Create(AOwner: TComponent);
begin
  inherited;
  Field := TComboBox.Create(Self);
  Relation := TComboBox.Create(Self);
  Edit := TEdit.Create(Self);
  CloseBtn := TButton.Create(Self);
  Self.Align := alTop;
  Field.Parent := Self;
  Relation.Parent := Self;
  Edit.Parent := Self;
  CloseBtn.Parent := Self;
  Field.Left := Margin;
  Relation.Left := Field.Width + Field.Left + Margin;
  Edit.Left := Relation.Width + Relation.Left + Margin;
  CloseBtn.Left := Edit.Width + Edit.Left + Margin;
  Field.Top := Margin;
  Relation.Top := Margin;
  Edit.Top :=  Margin;
  CloseBtn.Top := Margin;
  CloseBtn.Width := 2 * Margin;
  CloseBtn.Height := 2 * Margin;
  CloseBtn.Caption := 'X';
  CloseBtn.OnClick := CloseBtnClick;
  Field.Style := csOwnerDrawFixed;
  Relation.Style := csOwnerDrawFixed;
end;

function TPanelForFilters.GetStringForSQL(Names: array of string): String;
begin
  If (Field.ItemIndex <> -1) and (Relation.ItemIndex <> -1) then
    Result := Names[Field.ItemIndex] +
              PrepareRelation(Relation.ItemIndex, Edit.Text)
  else
    Result := '';
end;

function TPanelForFilters.PrepareRelation(Index: Integer; Arg: String): String;
begin
  case Index of
   0 .. 5: Result := ' ' + Ratio[Index] + QuotedStr(Arg) + ' ';
   6: Result := ' Starting with ' + QuotedStr(Arg) + ' ';
   7: Result := ' like ' + QuotedStr('%' + Arg + '%');
  end;
end;

procedure TPanelForFilters.SetOnDestroy(const Value: TNotifyEvent);
begin
  FOnDestroy := Value;
end;

procedure TPanelForFilters.SetParent(AParent: TWinControl);
begin
  Parent := AParent;
end;

end.
